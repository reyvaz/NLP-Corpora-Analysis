ngram.onegram.pairs <- function(ngramTable) {
    # Creates a list of n-gram:one-gram pairs from an (n+1)-gram list.
    #
    # Args:
    #           ngramTable: A table containing a list of (n+1)-grams in the 
    #           1st-column. Such table can be the outcome of get.phrasetable()
    #           from the ngram package. 
    # Returns:
    #           A data.table containing the lists of n-grams:one-gram pairs,  
    #           plus additional original columns.
    ptm <- proc.time()
    require(ngram)
    require(splitstackshape)
    cat("making 'n-gram:one-gram' pairs, time =", (proc.time() - ptm)[3], "\n")
    str <- as.character(ngramTable[1,1])
    wc  <- wordcount(str)
    ngramList <- ngramTable[,1]
    sg  <- cSplit(ngramList, splitCols = "ngrams", sep = " ")
    sg  <- sg[, phrase:=do.call(paste,.SD), .SDcols=-wc]
    pairs   <- data.table(sg[,(wc+1), with=FALSE], sg[,wc, with=FALSE])
    setnames(pairs, names(pairs)[2], "word")
    ncol <- dim(ngramTable)[2]
    if (ncol>1) {
        pairs <- cbind(pairs, ngramTable[,2:ncol]) 
    }
    cat("finished 'n-gram:one-gram' pairs. time=", (proc.time() - ptm)[3], "\n")
    return(pairs)
}
