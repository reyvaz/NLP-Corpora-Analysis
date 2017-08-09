request.ngram <- function(corpus, n = 1, wordsPerLine = NULL, binSize = NULL, 
                          minfreq = 1, minfreqdump = 2, dumpcycle = NULL, 
                          fullList = F){
    # Creates an n-gram list from a corpus. 
    #
    # Its purpose is to optimize speed and memory usage for large corpora by 
    # breaking out corpora and regularly dumping ngrams with low frequency. It 
    # may "overlook" important ngrams and/or undercount frequency for some 
    # ngrams depending on the argument values. For smaller corpora and/or more 
    # efficient systems, try make_ngram.R alone to avoid these issues. 
    #
    # Args:
    #       corpus: A character object containing a corpus
    #       n:      An integer equivalent to "n" for ngram. Default is 1
    #       wordsPerLine: (Optional) An integer vector of length=length(corpus) 
    #               with word counts for each line of the corpus.
    #       binSize: (Optional) An integer instructing the length of each corpus
    #               subset per iteration. Set low for large corpora or slower 
    #				systems.
    #       minfreq: An interger. It carries over to make.ngram(). It specifies 
    #               the minimum frequency required for an n-gram to be returned 
    #               from make.ngram() at every iteration. Default is 1 
    #               (Recommended).
    #       minfreqdump: An interger. It specifies the minimum frequency 
    #               required for an n-gram to be kept after a dumpcycle. Default 
    #               is 2.
    #       dumpcycle: (Optional) An integer specifying after how many  
    #               iterations the program should dump ngrams with accumulated 
    #               frequency < minfreqdump. Set low for larger corpora and/or
    #               less effcient systems. 
    #       fullList: Logical. If T, and minfreq < 2, it will return a list of 
    #               all unique ngrams. Default F (recommended)
    # Returns:
    #       A data.table or a list of data tables: 
    #               *If fullList is F (default) it returns a data.table with 
    #               requested n-grams in the 1st column and frequency in the 2nd
    #               *If fullList is T and minfreq < 2, it returns a list with 2 
    #               data.tables. The 1st data.table is as described above, and 
    #               the 2nd one contains the full list of unique ngrams.
    require(ngram)
    require(data.table)
    source("make_ngram.R")
    corpusLength <- length(corpus)
    ptm          <- proc.time()
    if(is.null(binSize)){
        binSize <- floor(corpusLength/6)
    }
    if(is.null(wordsPerLine)){
        wordsPerLine <- lapply(corpus[1:length(corpus)], 
                               function(x) wordcount(x))
        wordsPerLine <- as.numeric(unlist(wordsPerLine))
    }
    num_bins <- ceiling(corpusLength/binSize)
    if(is.null(dumpcycle)){
        dumpcycle <- num_bins
    }
    b        <- binSize*(num_bins-1)
    breaks   <- c(seq(0, b, binSize), corpusLength)
    ngram    <- data.table(ngrams=as.character(character()), V1=integer(), 
                        stringsAsFactors=FALSE) 
    if (fullList == T){
        if (minfreq > 1){
            cat("fullList can not be created if minfreq > 1... Returning
                ngram table without full list", "\n")
            fullList = F
        }
        if (minfreq < 2){
            uniquengrams <- data.table(ngram$ngrams)
            cat("fullList requested, the output will be a list object", 
                "\n")
        }
    }
    dumpIter <- -1 ## skips dumping 3 extra cycles at the beggining to minimize 
                   ## undercounting frequencies
    totalnGrams <- 0
    for (i in 1:num_bins){
        firstLine  <- breaks[i] + 1
        lastLine   <- breaks[i+1]
        subCorpus  <- corpus[firstLine:lastLine]
        wpl        <- wordsPerLine[firstLine:lastLine]
        subngram   <- make.ngram(subCorpus, wpl, n=n, minfreq=minfreq)
        subngram   <- data.table(subngram)
        if (fullList == T){
            tempUnique   <- data.table(subngram$ngrams)                      
            uniquengrams <- unique(rbind(uniquengrams, tempUnique))                 
            rm(tempUnique)                                                 
        }
        setnames(subngram,"freq", "V1")
        ngram    <- rbind(ngram, subngram[,1:2])
        ngram    <- ngram[, sum(V1, na.rm = TRUE), by=ngrams]
        dumpIter <- dumpIter + 1
        if (dumpIter > dumpcycle) {
            keep <- which(ngram$V1>minfreqdump-1)
            cat("Dumping at iter =", i, "time =", (proc.time() - ptm)[3], "\n")
            ngram <- ngram[keep,]
            dumpIter <- 1
        }
        rm(subngram)
        rm(wpl)
    }
    setnames(ngram, "V1", "freq")
    keep  <- which(ngram$freq>minfreq-1)
    ngram <- ngram[keep,]
    ngram <- ngram[order(-freq)]
    if (fullList == T){
        ngram <- list("ngram" = ngram, "fullngramList" = uniquengrams)
        rm(uniquengrams)
    }
    gc()
    return(ngram)
}