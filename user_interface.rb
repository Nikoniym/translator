class UserInterface
  def initialize
    text_input
    check_lang_and_translate_variant
    translate
  end

  private

  # Поле для вода текста, который необходимо перевести
  def text_input
    begin
      puts 'Введите текст для перевода:'

      @text = gets.chomp

      # Проверяем наличие текста в поле
      valid!
    rescue StandardError => e
      puts e.message

      retry
    end
  end

  # Определяем язык ввода и на его основании предлагаем варианты перевода
  def check_lang_and_translate_variant
    # Получаем язык введённого текста
    current_lang = Yandex::Translator.detect(@text)

    # Из всех вариантов перевода выбираем те что относятся к языку введённого текста
    @translate_variants = Yandex::Translator.get_langs.select { |translate_variant| translate_variant.match(/^#{current_lang}/) }

    puts 'Введите номер варианта перевода:'

    # Выводим варианты перевода данного текста
    @translate_variants.each_with_index do |translate_variant, index|
      puts "#{index} - #{translate_variant}"
    end
  end

  # Выбираем вариант перевода, и получаем результат.
  def translate
    result = gets.chomp.to_i

    # Если вариант указан неверно, то выводим сообщение об ошибки и повторяем ввод варианта
    if @translate_variants[result].nil?
      puts 'Ошибка ввода!!!', 'Введите номер варианта перевода из списка:'

      translate
    # Если указанный вариат введен верно, то показываем результат
    # И предлагаем ввести новое выражение для перевода
    else
      puts Yandex::Translator.translate(@text, @translate_variants[result])

      UserInterface.new
    end
  end

  # Сообщение об ошибке если поле ввода осталось пустым
  def valid!
    raise 'Текст не может быть пустым!!!' if @text.empty?
  end
end
