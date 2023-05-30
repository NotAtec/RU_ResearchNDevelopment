require "openai"

class Question
    attr_accessor :theQuestion, :answers, :correctAnswer
    def initialize(theQuestion, answers, correctAnswer)
        @theQuestion = theQuestion
        @answers = answers
        @correctAnswer = correctAnswer
    end
    def getAnswer(index)
        @answers[index]
    end
    def to_s
        return "question: #{theQuestion} \n optionA: #{answers[0]} \n optionB: #{answers[1]} \n optionC: #{answers[2]} \n optionD: #{answers[3]} \n answerNum: #{correctAnswer}"
    end
end

class QuestionGenerator
    attr_accessor :client
    def generateQuestions(topic, amount)
        generateSucces = false
        generateAttempts = 0
        succes = false
        while !succes
            while !generateSucces
                questionText = generate(topic, amount)
                #puts questionText
                generateAttempts += 1
                if (questionText != nil)
                    generateSucces = true
                end
            end
            resultingQuestions = filter(questionText, amount)
            if (resultingQuestions != nil) 
                succes = true
            end
        end
        return resultingQuestions
    end
    #private
    def generate(topic, amount)
        OpenAI.configure do |config|
            config.access_token = "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"
        end
        client = OpenAI::Client.new
        conversation = [{ role: "system", content: "You are a bot that makes " + amount.to_s + " multiple choice question about a given topic. Each multiple choice question has 4 possible answers. You always make sure that the right answer is provided at the bottom."},
                        {role: "user", content: topic}]
        response = client.chat(
            parameters: {
                model: "gpt-3.5-turbo", # Required.
                messages: conversation, # Required.
                temperature: 0.7,
            })
        #puts response
        return response.dig("choices", 0, "message", "content")
    end
    def filter(theString, amount)
        theArray = theString.split("\n")
        optionIndexes = findABCD(theArray)
        questionIndexes = findQues(theArray, amount)
        answerIndexes = findAns(theArray)
        storedQuestions = []
        if (optionIndexes.length == amount && questionIndexes.length == amount && answerIndexes.length == amount)
            #puts "answers grouped amount:#{amount}, questions:#{questionIndexes.length}, options:#{optionIndexes.length}, answers:#{answerIndexes.length}"
            #puts questionIndexes.to_s
            #puts optionIndexes.to_s
            #puts answerIndexes.to_s
            (0...amount).each do |q|
                questionPhrase = parseQues(theArray, q+1, questionIndexes[q], answerIndexes[q])
                optionA = parseOpt(theArray, "a", optionIndexes[q])
                optionB = parseOpt(theArray, "b", optionIndexes[q]+1)
                optionC = parseOpt(theArray, "c", optionIndexes[q]+2)
                optionD = parseOpt(theArray, "d", optionIndexes[q]+3)
                options = [optionA, optionB, optionC, optionD]
                answer = parseSingAns(theArray, answerIndexes[q])
                if (optionA == nil || optionB == nil || optionC == nil || optionD == nil || questionPhrase == nil || answer==nil)
                    return nil
                end
                fullQuestion = Question.new(questionPhrase, options, answer)
                storedQuestions.append(fullQuestion)
            end
        elsif (optionIndexes.length == amount && questionIndexes.length == amount && answerIndexes.length == 1)
            answerList = parseMultAns(theArray, answerIndexes[0], amount)
            #puts "answers grouped amount:#{amount}, questions:#{questionIndexes.length}, options:#{optionIndexes.length}, answers:#{answerIndexes.length}"
            #puts questionIndexes.to_s
            #puts optionIndexes.to_s
            #puts answerList.to_s
            (0...amount).each do |q|
                questionPhrase = parseQues(theArray, q+1, questionIndexes[q], answerIndexes[q])
                optionA = parseOpt(theArray, "a", optionIndexes[q])
                optionB = parseOpt(theArray, "b", optionIndexes[q]+1)
                optionC = parseOpt(theArray, "c", optionIndexes[q]+2)
                optionD = parseOpt(theArray, "d", optionIndexes[q]+3)
                options = [optionA, optionB, optionC, optionD]
                answer = answerList[q]
                if (optionA == nil || optionB == nil || optionC == nil || optionD == nil || questionPhrase == nil || answer==nil)
                    return nil
                end
                fullQuestion = Question.new(questionPhrase, options, answer)
                storedQuestions.append(fullQuestion)
            end
        else 
            #puts "answers grouped amout:#{amount}, questions:#{questionIndexes.length}, options:#{optionIndexes.length}, answers:#{answerIndexes.length}"
            #puts questionIndexes.to_s
            #puts optionIndexes.to_s
            #puts answerIndexes.to_s
            return nil
        end
        return storedQuestions
    end
    def findABCD(theArray) 
        indexes = []
        (0..theArray.length-3).each do |i|
            if (theArray[i][0] == "a" && theArray[i+1][0] == "b" && theArray[i+2][0] == "c" && theArray[i+3][0] == "d")
                indexes.append(i)
            else 
                if (theArray[i][0] == "A" && theArray[i+1][0] == "B" && theArray[i+2][0] == "C" && theArray[i+3][0] == "D")
                    indexes.append(i)
                end
            end
        end
        return indexes
    end
    def findQues(theArray, amount)
        indexes = []
        currentSearch = 1
        (0..theArray.length-3).each do |i|
            if (amount<currentSearch)
                break
            end
            if (theArray[i][0, currentSearch.to_s.length] == currentSearch.to_s)
                indexes.append(i)
                currentSearch += 1
                i += 3;
            end
        end
        return indexes
    end
    def findAns(theArray)
        indexes = []
        (0...theArray.length).each do |i|
            if (theArray[i][0, 6] == "answer" || theArray[i][0, 6] == "Answer" || theArray[i][0, 15] == "Correct answers" )
                indexes.append(i)
            end
        end
        return indexes
    end
    def parseQues(theArray, quesNum, index, maxIndex)
        if (theArray[index][0, 2+(quesNum.to_s.length)] == quesNum.to_s + ". ")
            if theArray[index].include? "?"
                return theArray[index][(quesNum.to_s.length+2)..theArray[index].index("?")]
            else 
                #puts "question not defined in 1 single line. unaccounted for case"
                return nil
            end
        elsif (theArray[index][0, 2+(quesNum.to_s.length)] == quesNum.to_s + ") ")
                if theArray[index].include? "?"
                    return theArray[index][(quesNum.to_s.length+2)..theArray[index].index("?")]
                else 
                    #puts "question not defined in 1 single line. unaccounted for case"
                    return nil
                end
        else 
            #puts "question did not start with \"Num. \" or \"Num) \", case unaccounted for"
            return nil
        end
    end
    def parseOpt(theArray, ansSymbol, index)
        if (theArray[index][0..2] == ansSymbol + ") " || theArray[index][0..2] == ansSymbol.upcase + ") " )
            return theArray[index][3...(theArray[index].length)]
        elsif (theArray[index][0..2] == ansSymbol + ". " || theArray[index][0..2] == ansSymbol.upcase + ". " )
            return theArray[index][3...(theArray[index].length)]
        else
            #puts "option did not start with \"a) \" or \"a. \", case unaccounted for"
            return nil
        end
    end
    def parseSingAns(theArray, index)
        if ((theArray[index][0..7] == "answer: " || theArray[index][0..7] == "Answer: ") && (theArray[index][9] == ")" || theArray[index][9] == "."))
            if "abcd".include? theArray[index][8]
                return "abcd".index(theArray[index][8])
            elsif "ABCD".include? theArray[index][8]
                return "ABCD".index(theArray[index][8])
            else
                #puts "character not recognized: #{theArray[index][8]}"
                return nil
            end
        elsif ((theArray[index][0..7] == "answer: " || theArray[index][0..7] == "Answer: ") && theArray[index].length ==9)
            if "abcd".include? theArray[index][8]
                return "abcd".index(theArray[index][8])
            elsif "ABCD".include? theArray[index][8]
                return "ABCD".index(theArray[index][8])
            else
                #puts "character not recognized: #{theArray[index][8]}"
                return nil
            end
        else 
            #puts "answer not formatted in format \"(a/A)nswer: a)\", \"(a/A)nswer: a.\""
            return nil
        end
    end
    def headerAndAnswers(theArray, index, amount) 
        if (theArray.length-index-1 != amount)
            return false
        end
        (0...amount).each do |a| 
            if !(theArray[index+1+a][0, (a+1).to_s.length] == (a+1).to_s && (theArray[index+1+a][(a+1).to_s.length..(a+1).to_s.length+1] == ". " || theArray[index+1+a][(a+1).to_s.length..(a+1).to_s.length+1] == ") "))
                #puts "(#{theArray[index+1+a][0, a.to_s.length]}) != (#{(a+1).to_s})"
                #puts "(#{theArray[index+1+a][a.to_s.length..a.to_s.length+1]}) != (. )"
                return false
            end
        end
        return true
    end
    def parseMultAns(theArray, index, amount)
        answerNum = []
        if headerAndAnswers(theArray, index, amount)
            (0...amount).each do |a| 
                if "abcd".include? theArray[index+a+1][3]
                    answerNum.append("abcd".index(theArray[index+a+1][3]))
                elsif "ABCD".include? theArray[index+a+1][3]
                    answerNum.append("ABCD".index(theArray[index+a+1][3]))
                else
                    #puts "character not recognized: #{theArray[index+a+1][3]}"
                    return nil
                end
            end
        else
            #puts "format not recognized"
            return nil
        end
        return answerNum
    end
end

questionGenerator = QuestionGenerator.new()

#How to use it:
# |
# v
#questionsResult = questionGenerator.generateQuestions("evolution", 3)
#puts questionsResult
#puts "script ended"