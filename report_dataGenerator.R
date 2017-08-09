# Generates the data for the exploration_report.Rmd
#
# Requires the files:
#       "en_US.blogs.txt", "en_US.news.txt", "en_US.twitter.txt" in the data
#       folder. 
# Requires the scripts:
#       "request_ngram.R", "make_ngram.R", "ngram_onegram_pairs.R"
#       "codify_tokens.R", "frequent_ngrams.R"
# Requires the packages:
#       "data.table", "ngram", "splitstackshape", "plyr"
# May require the "preprocess_corpus.R" script, the packages "tm", "qdap",
#       and the "badwords.txt" file if "orig_corpus.txt", "clean_corpus.txt" 
#       do not exist in the directory.
#
# Creates "reportWorkspace.RData", which contains tables with basic statistics
# of the corpora, subsets of words and ngrams tables with frequency counts. It 
# also contains the data files used by the basic trigram word predictor.

setwd("/Users/reysbar/MEGA/corpus_analysis")
startTime <- strftime(Sys.time(), format="%H:%M:%S")
cat("Starting Time", startTime, "\n")
require(data.table)
require(ngram)
source("request_ngram.R")
source("ngram_onegram_pairs.R")
source("codify_tokens.R")
source("frequent_ngrams.R")

blogPath        <- "data/en_US.blogs.txt"
newsPath        <- "data/en_US.news.txt"
twitPath        <- "data/en_US.twitter.txt"
origcorpusPath  <- "data/orig_corpus.txt"
cleancorpusPath <- "data/clean_corpus.txt"


if (!file.exists(origcorpusPath) | !file.exists(cleancorpusPath)) {
    blog   <- readLines(blogPath, skipNul = TRUE)
    news   <- readLines(newsPath, skipNul = TRUE)
    twit   <- readLines(twitPath, skipNul = TRUE)
    if (!file.exists(origcorpusPath)) {
        cat(origcorpusPath, "does not exist, creating it now", "\n")
        origcorpus <- c(blog, news, twit)
        write(origcorpus, file = origcorpusPath)
        rm(origcorpus)
    }
    if (!file.exists(cleancorpusPath)) {
        cat(cleancorpusPath, "does not exist, creating it now, this will",
            "take a while...", "\n")
        source("preprocess_corpus.R")
        blog <- preprocess.corpus(blog)
        news <- preprocess.corpus(news)
        twit <- preprocess.corpus(twit)
        cleancorpus <- c(blog, news, twit)
        write(cleancorpus, file = cleancorpusPath)
        rm(cleancorpus, preprocess.corpus)
    }
    rm(blog, news, twit)    ## although these are later used, need to clear
    gc()                    ##  memory for the heavy processes ahead. 
}

corpora <- c("blog", "news", "twit", "origcorpus", "cleancorpus")
statsRowNames <- c("File size (MB)", "Total lines (Thousands)", 
        "Total words (Millions)", "Avg words per line", "Max words in a line",
        "50pct dict", "75pct dict", "90pct dict")
corporaStats <- matrix(0, ncol = 5, nrow = 8)
colnames(corporaStats)  <- corpora
rownames(corporaStats)  <- statsRowNames
countsRowNames <- c("uniqueWords", "unique2grams", "unique3grams", 
                    "unique4grams")
ngramCounts           <- matrix(0, ncol = 5, nrow = 4)
colnames(ngramCounts) <- corpora
rownames(ngramCounts) <- countsRowNames
rm(countsRowNames, statsRowNames)

source("request_ngram.R")
for (j in 1:5) {
    corpusName <- corpora[j]
    pathName <- paste(corpusName, "Path", sep = "")
    filePath <- get(pathName)
    corpus   <- readLines(filePath, skipNul = TRUE)
    wpl      <- lapply(corpus[1:length(corpus)], function(x) wordcount(x))
    wpl      <- as.numeric(unlist(wpl))
    fileSize <- file.info(filePath)$size/(2^20)  ## converts to MB
    totWords <- sum(wpl)
    corporaStats[1,j] <- fileSize
    corporaStats[2,j] <- length(wpl)/(10^3)      ## converts to 1000s
    corporaStats[3,j] <- totWords/(10^6)         ## converts to millions
    corporaStats[4,j] <- mean(wpl)
    corporaStats[5,j] <- max(wpl)
    bin <- floor((5*10^6)/mean(wpl))    ## this makes each bin contain ~5M words
    for (n in 1:3){
        ngramName <- paste(corpusName, n, "gram", sep = "")
        cat("Starting", ngramName, "current time:", 
            strftime(Sys.time(), format="%H:%M:%S"), "\n")
        ngramList <- request.ngram(corpus, n = n, wordsPerLine=wpl, fullList=T,
                          binSize = bin, minfreq = 1, minfreqdump = 3, dump = 1)
        ngramCounts[n,j] <- dim(ngramList$fullngramList)[1]
        ngram <- ngramList$ngram
        rm(ngramList)
        gc()
        if (n == 1){
             corporaStats[6,j] <- max(which(cumsum(ngram$freq) < totWords*0.50))
             corporaStats[7,j] <- max(which(cumsum(ngram$freq) < totWords*0.70))
             corporaStats[8,j] <- max(which(cumsum(ngram$freq) < totWords*0.90))
             print(corporaStats)
        }
        if (j == 5 & n == 1){ ## saving this for coverage analysis in the report
            assign(ngramName,ngram)
        } else {
            ngram <- ngram[1:100]   ## Only a few of these needed for the report
            assign(ngramName,ngram)
        }
    }
    if (j == 5 & n == 3){ ## create predictor files
        n4gram <- request.ngram(corpus, n = 4, wordsPerLine = wpl, binSize=bin, 
                               minfreqdump = 2, minfreq = 1, dump = 2)
        n4gram <- ngram.onegram.pairs(n4gram)
        n4gram <- codify.tokens(n4gram)
        pcode  <- data.table(n4gram$phraseCode)
        wcode  <- data.table(n4gram$wordCode)
        n4gram <- data.table(n4gram$codedTable)
        n4gram <- frequent.ngram.pairs(n4gram)
        assign("pred", n4gram)
    }
    print(ngramCounts)
    rm(list = c(pathName))
    rm(corpusName, corpus, wpl, filePath, fileSize, totWords, bin, ngramName,
       pathName, ngram)
    gc()
}
ngramCounts <- ngramCounts[1:3,]
rm(j, n, request.ngram, codify.tokens, frequent.ngram.pairs, make.ngram, 
   ngram.onegram.pairs)
endTime <- strftime(Sys.time(), format="%H:%M:%S")
cat("Ending Time", endTime, "\n")
save.image("reportWorkspace.Rdata")
