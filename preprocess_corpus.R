preprocess.corpus <- function(x) {
    # Preprocess English text removing unwanted objects and making 
    # replacements and transformations. 
    #
    # Args:
    #       x: A character object
    #
    # Returns:
    #       A charather object stripped of email addresses, URLs, HTML, numbers, 
    #       symbols, contractions and some common profanity. Strings are 
    #       separated at ".". All output text is in lower-case.
    cat("Preprocessing corpus", "\n")
    ptm <- proc.time()
    require(tm)
    require(qdap)
    require(stringr)
    x <- tolower(x)
    email  <- paste("([_a-z0-9-]+(\\.[_a-z0-9-]+)*@[a-z0-9-]+",
                    "(\\.[a-z0-9-]+)*(\\.[a-z]{2,4}))", sep = "")
    x <- gsub(email, "", x)                              ## remove emails
    x <- gsub("<[^<>]+>", "", x)                         ## remove HTML
    x <- gsub("http\\S+\\s*|www\\S+\\s*", "", x)         ## remove URLs
    acron <- "(?<=[\\s\\.][a-z])\\."                     ## acronym pattern
    x <- gsub(acron,"", x, perl = TRUE) 
    usedTime <- (proc.time() - ptm)[3]
    x <- replace_abbreviation(x)                         ## <- HEAVY process
    usedTime <- (proc.time() - ptm)[3]
    x <- replace_contraction(x)                          ## <- HEAVY process
    usedTime <- (proc.time() - ptm)[3]
    x <- unlist(strsplit(x, "[.]"))                      ## cut lines at periods
    x <- tolower(x)
    badStems  <- readLines("badstems.txt", skipNul = T)
    badLines  <- str_detect(x, paste(badStems, collapse = '|'))
    goodIndex <- which(badLines==F)
    x         <- x[goodIndex]
    usedTime  <- (proc.time() - ptm)[3]
    badWords  <- readLines("badwords.txt", skipNul = T)
    badWords  <- paste("\\b", badWords, "\\b", sep ="")
    badLines  <- str_detect(x, paste(badWords, collapse = '|'))
    goodIndex <- which(badLines==F)
    x         <- x[goodIndex]
    usedTime  <- (proc.time() - ptm)[3]
    x <- gsub("'[s]", "", x)                            ## remove remaining 's
    x <- gsub("[^[:alpha:][:space:]]", "", x)           ## keep letters only
    x <- stripWhitespace(x)
    x <- gsub("^\\s+|\\s+$", "", x)                     ## strip space at edges
    x <- x[sapply(x, nchar) > 1]                        ## remove empty lines
    usedTime <- (proc.time()-ptm)[3]
    cat("Preprocessing corpus finished. Time elapsed =", usedTime, "\n")
    return(x)
}