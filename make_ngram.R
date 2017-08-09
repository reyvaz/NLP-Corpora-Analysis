make.ngram <- function(corpus, wordsPerLine=NULL, n=2, minfreq=1) {
    # Creates an n-gram list from a corpus. For very large corpora try
    # request_ngram.R
    #
    # Args:
    #       corpus:  Is a type character object containing a corpus
    #       wordsPerLine: (Optional) An integer vector of length=length(corpus) 
    #                with word counts for each line of the corpus.
    #       n:       An integer equivalent to "n" for n-gram.
    #       minfreq: An integer specifying the minimum number of occurences 
    #                required for an n-gram to be included in the output table
    #                default is 1.
    #
    # Returns:
    #       A data.frame: 1st column contains requested n-grams, 2nd and 3rd 
    #       columns list frequency and probability of each ngram respectively. 
    require(ngram)
    if(is.null(wordsPerLine)){
        wordsPerLine <- lapply(corpus[1:length(corpus)], 
                               function(x) wordcount(x))
        wordsPerLine <- as.numeric(unlist(wordsPerLine))
    }
    keep         <- which(wordsPerLine > n-1)
    temp_corpus  <- corpus[keep]
    ngramObject  <- ngram(temp_corpus, n=n)
    ngramTable   <-get.phrasetable(ngramObject) 
    keep         <- which(ngramTable[,2]>minfreq-1)
    ngramTable   <- ngramTable[keep,] 
    return(ngramTable)
}