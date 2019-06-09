require 'spec_helper'

describe Yandex::Translator do
  let(:api_key) { 'trnsl.1.1.20190609T072448Z.38d12f9bdcb82af0.47cf186214712731e7c53c7a3e67e159ac8d1056' }

  subject(:translator) { Yandex::Translator.new(api_key) }

  describe '#translate' do
    let(:translate_url) { 'https://translate.yandex.net/api/v1.5/tr.json/translate' }
    let(:translate_request_body) { "text=Car&lang=ru&key=#{api_key}" }
    let(:translate_response_body) do
      '{"code":200, "lang": "en-ru", "text": ["Автомобиль"]}'
    end

    let!(:translate_request) do
      stub_request(:post, translate_url)
        .with(body: translate_request_body)
        .to_return(
          body: translate_response_body,
          headers: {'Content-Type' => 'application/json'}
        )
    end

    it 'triggers correct yandex translation url' do
      translator.translate('Car', 'ru')
      expect(translate_request).to have_been_made.once
    end

    it 'returns translalation' do
      expect(translator.translate('Car', 'ru')).to eq 'Автомобиль'
    end

    it 'accepts options' do
      translator.translate('Car', from: :ru)
      expect(translate_request).to have_been_made.once
    end

    context 'with two languages' do
      let(:translate_request_body) { "text=Car&lang=en-ru&key=#{api_key}" }

      it 'accepts options' do
        translator.translate('Car', from: :en, to: :ru)
        expect(translate_request).to have_been_made.once
      end

      it 'accepts languages list' do
        translator.translate('Car', :ru, :en)
        expect(translate_request).to have_been_made.once
      end
    end

    context 'when server responds with invalid "lang" parameter error' do
      let(:translate_request_body) { "text=Car&lang=ru-ru&key=#{api_key}" }

      let(:translation_url) do
        'https://translate.yandex.net/api/v1.5/tr.json/translate?' \
        "key=#{api_key}&lang=ru-ru&text=Car"
      end

      let(:translate_response_body) do
        '{"code": 401,  "message": "API key is invalid"}'
      end

      it 'returns translation error' do
        expect{
          translator.translate('Car', 'ru', 'ru')
        }.to raise_error(Yandex::ApiError, "API key is invalid")
      end
    end
  end

  describe '#detect' do
    let(:detect_url) { "https://translate.yandex.net/api/v1.5/tr.json/detect" }
    let(:detect_request_body) { "text=Car&key=#{api_key}" }
    let(:decect_response_body) { '{"code": 200, "lang": "en"}' }
    let!(:detect_request) do
      stub_request(:post, detect_url)
      .with(body: detect_request_body)
      .to_return(
        body: decect_response_body,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    it 'hits correct url' do
      translator.detect('Car')
      expect(detect_request).to have_been_made.once
    end

    it 'returns detected language' do
      expect(translator.detect('Car')).to eq 'en'
    end

    context 'when response does not contains any language' do
      let(:decect_response_body) { '{"code": 200, "lang": ""}' }

      it 'returns nil' do
        expect(translator.detect('Car')).to be_nil
      end
    end
  end

  describe '#langs' do
    let(:langs_url) { "https://translate.yandex.net/api/v1.5/tr.json/getLangs" }
    let(:langs_request_body) { "key=#{api_key}" }
    let(:langs_response_body) { '{"dirs": ["en-ru"]}' }
    let!(:langs_request) do
      stub_request(:post, langs_url)
      .with(body: langs_request_body)
      .to_return(
        body: langs_response_body,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    it 'hits correct url' do
      translator.langs
      expect(langs_request).to have_been_made.once
    end

    it 'returns array of dirs' do
      expect(translator.langs).to eq ['en-ru']
    end
  end
end
