frequent.ngram.pairs <- function(x, m=dim(x)[1], n=3) {
    # Reduces the vertical dimention of the n-gram:one-gram matrix to include  
    # at most the "n" most frequent phrase:word pairs.
    #
    # Args:
    #       x:  is a data frame containing n-gram:one gram pairs, their IDs and
    #           also a column for frequency
    #       m:  the maximun number of rows to be considered
    #       n:  maximum number of choices for each phrase token
    # Returns:
    #       A reduced data frame containing only IDs and freq
    require(data.table)
    ptm <- proc.time()
    cat("Reducing to frequent ngrams, size before reduction:", dim(x)[1], "\n")
    m = min(dim(x)[1], m)
    x <- data.table(x[1:m,c(1,3,5)])
    index <- c(1:m)
    x     <- cbind(index, x)
    choice <- x[0,]
    
    for (i in 1:n){
        cat("finding", i, "most frequent. t =", (proc.time() - ptm)[3], "\n")
        mostFreq  <- x[x[, .I[which.max(freq)], by=idPhrase]$V1]
        idx       <- mostFreq$index
        choice    <- rbind(choice, x[idx,])
        x         <- x[-idx,]
        x$index   <- c(1:dim(x)[1])
    }
    choice <- choice[,-1]
    cat("finished frequent ngrams, t =", (proc.time() - ptm)[3], "\n")
    return(choice)
}
