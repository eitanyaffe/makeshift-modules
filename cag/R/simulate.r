# random sequence
seq.rnd=function(N, dummy=F)
{
    if (dummy) {
        return(rep(0, N))
    } else {
        seq = floor(runif(N, min=1, max=5))
        seq[seq>4] = 4
        seq[seq<1] = 1
        return (seq)
    }
}

# delete range by placing NAs
del=function(seq, from, to) {
    if (from<1 || to > length(seq))
        stop("error")
    seq[from:to] = NA
    seq
}

# substitute
sbs=function(seq, coords, nts) {
    result = seq
    for (i in 1:length(coords)) {
        i.seq = nts[[i]]
        coord = coords[i]
        n.seq = length(i.seq)
        result[coord:(coord+n.seq-1)] = i.seq
    }
    result
}

# insert
ins=function(seq, coords, nts) {
    result = seq[1:(coords[1]-1)]
    for (i in 1:length(coords)) {
        i.seq = nts[[i]]
        result = c(result, i.seq)
        from = coords[i]
        to = ifelse(i<length(coords), coords[i+1]-1, length(seq))
        result = c(result, seq[from:to])
    }
    result
}

# place range into random sequence context
embed=function(seq, from, to, N.context=100)
{
    left.seq = seq.rnd(N.context)
    right.seq = seq.rnd(N.context)
    c(left.seq, seq[from:to], right.seq)
}

simulate=function(seed=1, ofn.ref, odir.reads)
{
    set.seed(seed)
    dummy = T

    # reference
    ref = seq.rnd(100)

    # TBD save ref into fasta

    # start from ref
    seq1 = 1:100

    # introduce some edits
    seq1 = ref
    seq1 = sbs(seq1, coords=c(10,20), nts=list(seq.rnd(2,dummy=dummy), seq.rnd(3,dummy=dummy)))
    seq1 = del(seq1, from=30, to=32)
    seq1 = del(seq1, from=40, to=40)
    seq1 = ins(seq1, coords=c(50,60), nts=list(seq.rnd(2,dummy=dummy), seq.rnd(3,dummy=dummy)))
}

