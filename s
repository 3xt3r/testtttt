Детальный разбор тестов
ТЕСТ
НАЗНАЧЕНИЕ
ЧТО ПРОВЕРЯЕТ
КЛЮЧЕВЫЕ АССЕРЦИИ
HasFourFormaters()
Валидация параметров
Работа с допустимыми режимами кодировки (ascii, ebcdic, utf-8 и др.) и проверка null-stream
Ожидает ArgumentNullException при передаче null потока; выбрасывает InvalidOperationException при неизвестном режиме ("123")
RawOutputStableParserTest_BadHexFormat()
Парсинг hex-данных
Строгость валидации шестнадцатеричных строк в выводе tshark
Корректно пропускает служебные строки (===, Follow:, Node:); выбрасывает FormatException при длине hex-строки, не кратной 2
RawOutputStableParserTest_BadNodeFormat()
Парсинг метаданных узлов
Защита от дублирования адресов узлов в потоке
Успешно парсит Node 0; выбрасывает FormatException с текстом "Input data has duplicate Node: Node0..." при повторном появлении того же узла
ShouldReturnFollowStreamInAsciiFormat()
End-to-end тест потока
Полное преобразование TCP-потока из hex в ASCII с сохранением метаданных
Результат и StreamParts не null; Meta.Sides содержит 2 узла с верными IP:порт; порядок StreamParts соответствует ожидаемому (Node0, Node1, Node1, Node0); текстовое представление совпадает с эталоном
LoadPcapPackets_CalcPagesFromCache_Success()
Пагинация и кеширование
Оптимизация сканирования дампа и формирование CLI-команд
Проверяет точное совпадение аргументов tshark (-a "packets:X", -o gui.column.format:..., -Y "frame.number >= Y && ..."); валидирует заполнение IMemoryCache диапазонами страниц (1→(1,5), 2→(6,10) и т.д.)
