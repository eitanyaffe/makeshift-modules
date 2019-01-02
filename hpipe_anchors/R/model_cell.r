#####################################################################################
# Utility functions
#####################################################################################

format.number=function(num)
{
  size = c(10^9, 10^6, 10^3)
  name = c("G", "M", "K")
  for (i in 1:length(size))
    if (num > size[i])
      return (paste(round(num/size[i]), name[i], sep=""))
  return (num)
}

counts2labels=function(F.seed)
{
  N = dim(F.seed)[1]
  result = vector("character", N)
  for (i in 1:N)
  {
    count = F.seed[i,"count"]
    total = F.seed[i,"total"]
    count = format.number(count)
    total = format.number(total)
    result[i] = paste(count, "/", total, sep="")
  }
  result
}


counts2probs=function(F.seed)
{
  N = dim(F.seed)[1]
  probs = vector("numeric", N)
  for (i in 1:N)
    probs[i] = F.seed[i,"count"] / F.seed[i,"total"]
  probs[!is.finite(probs)] = 0
  probs = probs / median(probs)
  result = cbind(F.seed[,1:2], probs)
  result
}

get.seeds=function(count.table, field="frag_len_bin", is.const=T)
{
  cat(sprintf("computing seed function for %s\n", field))
  bfields = paste(field, c(1, 2), sep="")
  keys = count.table[, bfields]
  keys = unique(keys)
  ind = keys[,1] <= keys[,2]
  keys = keys[ind,]
  N = dim(keys)[1]
  count = vector("integer", N)
  total = vector("integer", N)

  for (i in 1:N)
  {
    bin1 = keys[i,1]
    bin2 = keys[i,2]
    ind = (count.table[,bfields[1]] == bin1 & count.table[,bfields[2]] == bin2) |
          (count.table[,bfields[1]] == bin2 & count.table[,bfields[2]] == bin1)
    tmp = count.table[ind,]
    count[i] = sum(as.numeric(tmp$count)) + ifelse(is.const,0,1)
    total[i] = sum(as.numeric(tmp$total)) + ifelse(is.const,0,1)
  }
  result = cbind(keys, count, total)
  rownames(result)=NULL
  result
}

extend.func=function(func)
{
  ind = func[,1] != func[,2]
  tmp = func[ind,c(2,1,3)]
  names(tmp) = names(func)
  rbind(func, tmp)
}

append.func.to.counts=function(count.table, fields, functions, suffix)
{
    result = count.table
    for (i in 1:length(fields)) {
        field = fields[i]
        field.result = paste(field, suffix, sep="_")
        func = extend.func(functions[[i]])
        bfields = paste(field, c(1, 2), sep="")

        keys = paste(count.table[,bfields[1]], count.table[,bfields[2]], sep="_")
        lu.keys = paste(func[,1], func[,2], sep="_")
        lu.values = func[,3]
        indices = as.numeric(factor(keys, levels=lu.keys))
        values = lu.values[indices]
        result[,field.result] = values
    }

    fields1 = paste(fields, 1, sep="")
    fields2 = paste(fields, 2, sep="")
    # count.table = count.table[,c(fields1, fields2, "count", "total", fields)]
    result
}

get.func.value=function(func, key1, key2)
{
  ind = func[,1] == key1 & func[,2] == key2
  if (sum(ind) != 1)
    stop("more than one value")
  func[ind, "probs"]
}

# fit into segment [0,1]
make.prob=function(P) {
    R = P
    R = R - min(R)
    R = R / max(R)
    R
}

#####################################################################################
# Algorithm functions
#####################################################################################

compute.prior=function(count.table,
    fields, functions,
    fields.spur, functions.spur, Pr.spur,
    min.probability=10^-100)
{
    table = append.func.to.counts(count.table=count.table, fields=fields, functions=functions, suffix="3C")
    table = append.func.to.counts(count.table=table, fields=fields.spur, functions=functions.spur, suffix="spur")
    factors.spur = paste(fields.spur, "spur", sep="_")
    factors.3C = paste(fields, "3C", sep="_")

    N = dim(table)[1]

    prod.spur = rep(Pr.spur, N)
    for (i in 1:length(factors.spur))
        prod.spur = prod.spur * table[,factors.spur[i]]

    prod.3C = rep(1.0, N)
    for (i in 1:length(factors.3C))
        prod.3C = prod.3C * table[,factors.3C[i]]

    prob = prod.spur + prod.3C

    bottom = max(min.probability / prob)
    top = min((1-min.probability) / prob)
    optimal = sum(table$count) / sum(prob)
    middle = (top + bottom) / 2

    if (optimal > bottom && optimal < top) {
        cat(sprintf("optimal prior: range=(%g,%g), result=%g\n", bottom, top, optimal))
        Pr = optimal
    } else {
        cat(sprintf("middle prior: range=(%g,%g), result=%g\n", bottom, top, middle))
        Pr = middle
    }
    Pr
}

# use ML to compute seed functions
compute.ll=function(
    count.table,
    fields, functions, Pr,
    fields.spur, functions.spur, Pr.spur)
{
    table = append.func.to.counts(count.table=count.table, fields=fields, functions=functions, suffix="3C")
    table = append.func.to.counts(count.table=table, fields=fields.spur, functions=functions.spur, suffix="spur")
    factors.spur = paste(fields.spur, "spur", sep="_")
    factors.3C = paste(fields, "3C", sep="_")

    table = table[table$total!=0,]

    N = dim(table)[1]

    # products for spurious and 3C
    prod.spur = rep(Pr.spur, N)
    for (i in 1:length(factors.spur))
        prod.spur = prod.spur * table[,factors.spur[i]]
    prod.3C = rep(1.0, N)
    for (i in 1:length(factors.3C))
        prod.3C = prod.3C * table[,factors.3C[i]]
    P_k = prod.spur + Pr * prod.3C

    # avoid taking log too close to zero
    log.margin = 100
    # cat(sprintf("P log gap: %f\n", max(-min(log10(P_k)), -min(log10(1-P_k)))))
    if (any(P_k < 10^-log.margin) || any((1-P_k) < 10^-log.margin))
        cat(sprintf("warning: P_k value close to 0 or 1 (epsilon=10^-100)\n"))

    N_k = table$count
    M_k = table$total - N_k
    result.v = N_k*log(P_k) + M_k*log(1-P_k)
    result = sum(result.v)

    if (is.nan(result)) {
        stop("NaN found, cannot proceed. Possibly reduce the number of model parameters")
    }

    result
}

# single step in alternating algorithm:
#  maximize one function, hold other const
maximize.ll=function(
    count.table, fields, functions, Pr,
    fields.spur, functions.spur, Pr.spur,
    opt.field)
{
    table = append.func.to.counts(count.table=count.table, fields=fields, functions=functions, suffix="3C")
    table = append.func.to.counts(count.table=table, fields=fields.spur, functions=functions.spur, suffix="spur")

    factors.spur = paste(fields.spur, "spur", sep="_")
    factors.3C = paste(fields, "3C", sep="_")
    factors.3C.const = factors.3C[-match(opt.field, fields)]

    table = table[table$total!=0,]

    # optimize each key separately
    bfields = paste(opt.field, 1:2, sep="")
    func = functions[[opt.field]]
    keys = func[,1:2]

    print(paste("optimizing", dim(keys)[1], "values for field", opt.field))
    probs = vector("numeric", dim(keys)[1])
    for (k in 1:dim(keys)[1]) {
        key1 = keys[k,1]
        key2 = keys[k,2]
        prev.value = get.func.value(functions[[opt.field]], key1, key2)

        ind = (table[,bfields[1]] == key1 & table[,bfields[2]] == key2) |
            (table[,bfields[2]] == key1 & table[,bfields[1]] == key2)
        table.key = table[ind,]
        N = dim(table.key)[1]

        if (N == 0) {
            probs[k] = prev.value
            next
        }

        # products for spurious and 3C
        prod.spur = rep(Pr.spur, N)
        for (i in 1:length(factors.spur))
            prod.spur = prod.spur * table.key[,factors.spur[i]]
        prod.3C.const = rep(1.0, N)
        for (i in 1:length(factors.3C.const))
            prod.3C.const = prod.3C.const * table.key[,factors.3C.const[i]]

        N_k = table.key[,"count"]
        M_k = table.key[,"total"] - N_k

        ll = function(alpha) {
            sapply(alpha, function(alpha) {
                sum(N_k*log(prod.spur + Pr*prod.3C.const*alpha) + M_k*log(1-(prod.spur + Pr*prod.3C.const*alpha)))
            })
        }

        lower.bound = 0
        upper.bound = min(1/(prod.spur + Pr*prod.3C.const))
        start = prev.value
        if (start > upper.bound) start = upper.bound
        if (start < lower.bound) start = lower.bound

        A = matrix(c(1, -1), 2, 1)
        B = matrix(c(-lower.bound, upper.bound), 2, 1)

        mnr = maxBFGS(ll, start=start, constraints=list(ineqA=A, ineqB=B))
        if (mnr$code != 0)
            stop(mnr$message)

        probs[k] = mnr$estimate
    }

    cbind(keys, probs)
}

#####################################################################################
# Wrapper functions
#####################################################################################

learn.model.file=function(spurious.model.prefix, model.prefix, model.params, fields)
{
    fields.spur = fields[-match("anchor",fields)]
    fields = fields[-match("abundance_bin",fields)]

    ifn.count = paste(model.prefix, ".nm", sep="")
    count.table = read.delim(ifn.count, stringsAsFactors=F)

    count.table$count = count.table$count + 1

    if (sum(count.table$count) < 10)
        stop("<10 contacts found, cannot learn model")

    F.seed = list()
    functions = list()
    seed.labels = list()
    for (field in fields) {
        is.const = (model.params[[field]]$type == "const")
        F.seed[[field]] = get.seeds(count.table, field, is.const=is.const)
        functions[[field]] = counts2probs(F.seed[[field]])
        seed.labels[[field]] = counts2labels(F.seed[[field]])
    }

    # save functions to file
    for (i in 1:length(fields)) {
        field = fields[i]
        func = functions[[i]]
        func = func[order(func[,1], func[,2]),]
        func[,3] = round(func[,3],8)
        write.table(func, paste(model.prefix, "_", fields[i], "_seed.f", sep=""),
                    quote=F, col.names=T, row.names=F, sep="\t")
    }

    # replace seed function for const functions (e.g. mappability bias)
    for (field in fields) {
        if (field == "anchor")
            next
        if (model.params[[field]]$type == "const") {
            seed.fn = paste(model.prefix, "_", field, ".f", sep="")
            cat(sprintf("loading const function for field: %s\n", field))
            functions[[field]] = read.delim(seed.fn)
            seed.labels[[field]] = NULL
        }
    }

    # load spurious model
    functions.spur = list()
    for (field in fields.spur) {
        ifn = paste(spurious.model.prefix, "_", field, ".f", sep="")
        cat(sprintf("loading spurious function for field: %s\n", field))
        functions.spur[[field]] = read.delim(ifn)
    }
    Pr.spur = read.delim(paste(spurious.model.prefix, ".prior", sep=""), header=F)[1,1]
    cat(sprintf("spurious prior: %f\n", Pr.spur))

    Pr = compute.prior(
        count.table=count.table,
        fields=fields, functions=functions,
        fields.spur=fields.spur, functions.spur=functions.spur, Pr.spur=Pr.spur)

    pfn = paste(model.prefix, ".prior", sep="")
    write.table(list(prior=Pr), pfn,
                quote=F, col.names=F, row.names=F, sep="\t")
    cat(sprintf("generating prior file %s\n", pfn))

    ll = compute.ll(count.table=count.table,
        fields=fields, functions=functions, Pr=Pr,
        fields.spur=fields.spur, functions.spur=functions.spur, Pr.spur=Pr.spur)

    print(paste("Initial LL=", ll, sep=""))
    system(paste("echo ", ll, " > ", model.prefix, ".initial_ll", sep=""))

    max.iter = 10
    if (length(fields) > 1) {
        for (i in 1:max.iter) {
            print(paste(">>> Iteration #", i, sep=""))
            for (j in 1:length(fields)) {
                field = fields[j]
                if (model.params[[field]]$type == "const" && field != "anchor")
                    next

                result = maximize.ll(
                    count.table=count.table,
                    fields=fields, functions=functions, Pr=Pr,
                    fields.spur=fields.spur, functions.spur=functions.spur, Pr.spur=Pr.spur,
                    opt.field=field)
                functions[[j]] = result

                ll.new = compute.ll(count.table=count.table,
                    fields=fields, functions=functions, Pr=Pr,
                    fields.spur=fields.spur, functions.spur=functions.spur, Pr.spur=Pr.spur)

                delta = round(ll.new-ll,2)
                print(paste("LL delta=", delta, sep=""))
                ll = ll.new
            }
            if (delta < 1 && i > 2) {
                system(paste("echo ", ll, " > ", model.prefix, ".final_ll", sep=""))
                break
            }
        }
    }

    # save functions to file
    for (i in 1:length(fields)) {
        field = fields[i]
        if (model.params[[field]]$type == "const" && field != "anchor")
            next
        func = functions[[i]]
        func = func[order(func[,1], func[,2]),]
        func[,3] = round(func[,3],8)
        ofn = paste(model.prefix, "_", fields[i], ".f", sep="")
        save.table(func, ofn)
    }
}

learn.model=function(spurious.model.prefix, model.prefix,model.fn)
{
    library(maxLik)

    model.table = load.table(model.fn)
    model.params = list()
    fields = NULL
    for (i in 1:dim(model.table)[1]) {
        field = model.table[i,"field"]
        type = model.table[i,"type"]
        if (type != "const" && type != "optimize")
            stop("in model table type must be 'optimize' or ' const'")
        model.params[[ field ]] = list(size=model.table[i,"size"], type=type)
        fields = c(fields, field)
    }

    learn.model.file(spurious.model.prefix=spurious.model.prefix, model.prefix=model.prefix, model.params=model.params, fields=fields)
}

rl=function() {
    source("md/anchors/R/model.r")
}
