require "openai"

#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
#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 actual key
class QuestionGenerator
    attr_accessor :client
    def initializer
        @key = "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"
    end
    def generate_question2(topic, amount)
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
                stream: proc do |chunk, _bytesize|
                    print chunk.dig("choices", 0, "delta", "content")
                end
            })
        response
    end
end

questionGenerator = QuestionGenerator.new()
questionGenerator.generate_question2("Star Wars", 10)