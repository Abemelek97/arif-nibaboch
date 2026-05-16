class TranslateDiscussionQuestionJob < ApplicationJob
  queue_as :default

  def perform(question_id, target_lang = "ZH")
    unless Rails.env.production?
      Rails.logger.info "[TranslateDiscussionQuestionJob] Skipped API translation in #{Rails.env} environment to save resources."
      return
    end

    question = DiscussionQuestion.find_by(id: question_id)
    return unless question && question.content.present?

    translated_text = TranslationService.new(question.content, target_lang: target_lang).call

    if translated_text.present?
      translation_record = question.question_translations.find_or_initialize_by(language_code: target_lang)
      translation_record.update(content: translated_text)

      if [ "ZH", "ZH-HANT" ].include?(target_lang)
        pinyin_content = Pinyin.t(translated_text, tonemarks: true)
        pinyin_record = question.question_translations.find_or_initialize_by(language_code: "PINYIN")
        pinyin_record.update(content: pinyin_content)
      end
    end
  end
end
