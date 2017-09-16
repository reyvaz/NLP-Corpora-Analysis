codify.tokens <- function(x) {
    # Assigns IDs to each ngram token and to each onegram token in an  
    # ngram:onegram pairs table 
    #
    # Args:
    #       x:  is a data frame containing n-gram:one gram pairs.
    # Returns:
    #       A list containing 3 data frames: (1) A data frame containing each 
    #       unique phrase with its corresponding ID. (2) The original data frame 
    #       with word and phrase IDs columns added. (3) A data frame containing 
    #		each unique onegram in x with its corresponding assigned ID.
    library(plyr)
    cat("codifying tokens", "\n")
    phrase   <- unique(x$phrase)
    m        <- length(phrase)
    idPhrase <- c(1:m)
    phraseCode <- data.frame(idPhrase, phrase)
    x <- join(phraseCode, x) 
   
    word <- unique(x$word)
    m <- length(word)
    idWord <- c(1:m)
    wordCode <- data.frame(idWord, word)     
    x <- join(wordCode, x)
    x <- x[order(-x[,5]),]
    outputTables <- list("phraseCode" = phraseCode, 
                         "wordCode" = wordCode,
                         "codedTable" = x)
    cat("finished codifying tokens", "\n")
    return(outputTables)
}