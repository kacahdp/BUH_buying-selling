	  
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Организация = БухгалтерскийУчетПереопределяемый.ПолучитьЗначениеПоУмолчанию("ОсновнаяОрганизация"); 
	
	Если Не ЗначениеЗаполнено(Организация) Тогда
		ОсновнаяОрганизация = Справочники.Организации.ОрганизацияПоУмолчанию(Пользователи.ТекущийПользователь());
	КонецЕсли; 
	
	Если Не ЗначениеЗаполнено(Организация) Тогда
		ОсновнаяОрганизация = ПолучитьОсновнаяОрганизация();
	КонецЕсли;
	
	ИспользоватьНесколькоСкладов = Константы.ИспользоватьНесколькоСкладов.Получить(); 
	Если Не ИспользоватьНесколькоСкладов Тогда
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	Склады.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Склады КАК Склады
		|ГДЕ
		|	НЕ Склады.ПометкаУдаления";
		
		РезультатЗапроса = Запрос.Выполнить();
		
		Выборка = РезультатЗапроса.Выбрать();
		
		Если Выборка.Следующий() Тогда 	
			Склад = Выборка.Ссылка;	
		КонецЕсли;	
	КонецЕсли;
	
КонецПроцедуры	

&НаСервере
Функция ПолучитьОсновнаяОрганизация() Экспорт
	
	ОсновнаяОрганизация = Справочники.Организации.ПустаяСсылка();
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 2
	|    Организации.Ссылка КАК Организация
	|ИЗ
	|    Справочник.Организации КАК Организации
	|ГДЕ
	|    НЕ Организации.ПометкаУдаления
	|    И НЕ Организации.Предопределенный";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() И Выборка.Количество() = 1 Тогда
		ОсновнаяОрганизация = Выборка.Организация;
	КонецЕсли;
	
	Возврат ОсновнаяОрганизация;
	
КонецФункции
	  
&НаКлиенте
Процедура ЗагрузитьПокупки(Команда)
	
	Если ФайлПокупки = "" Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не указан путь к файлу");
		Возврат;
	КонецЕсли;
	
	ДД = Новый ДвоичныеДанные(ФайлПокупки);
    АдресВременногоХранилища = ПоместитьВоВременноеХранилище(ДД, Новый УникальныйИдентификатор);		
	ЗагрузкаВТабличныйДокументНаСервере(АдресВременногоХранилища);
	
КонецПроцедуры 

&НаКлиенте
Процедура ЗагрузитьПродажи(Команда)
	
	Если ФайлПродажи = "" Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не указан путь к файлу");
		Возврат;
	КонецЕсли;
	
	ДД = Новый ДвоичныеДанные(ФайлПродажи);
	АдресВременногоХранилища = ПоместитьВоВременноеХранилище(ДД, Новый УникальныйИдентификатор);		
	ЗагрузкаВТабличныйДокументНаСервере(АдресВременногоХранилища);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузкаВТабличныйДокументНаСервере(АдресВременногоХранилища)
	
	ДД 					= ПолучитьИзВременногоХранилища(АдресВременногоХранилища); 
	ИмяВременногоФайла 	= ПолучитьИмяВременногоФайла(Расширение); 
	ДД.Записать(ИмяВременногоФайла);
	
	ТабДок = Новый ТабличныйДокумент;
	ТабДок.Прочитать(ИмяВременногоФайла);
	
	ОбластиТаб = ТабДок.Область(1, 1, ТабДок.ВысотаТаблицы, ТабДок.ШиринаТаблицы);
	
	Построитель = Новый ПостроительЗапроса;
	Построитель.ИсточникДанных = Новый ОписаниеИсточникаДанных(ОбластиТаб);  
	Построитель.Выполнить();
	
	ТабДанные = Построитель.Результат.Выгрузить();	
		
	Если Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаПокупки Тогда
		ТаблицаЗагрузки = Объект.Покупки;   
		ВидДоговора 	= ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.СПоставщиком");
	ИначеЕсли Элементы.Страницы.ТекущаяСтраница = Элементы.СтрницаПродажи Тогда 
		ТаблицаЗагрузки = Объект.Продажи;
		ВидДоговора 	= ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.СПокупателем");
	КонецЕсли; 
	
	ТаблицаЗагрузки.Очистить();
	
	КолонкаНомерДокумента 		= ТабДанные.Колонки[0].Имя;
	КолонкаДатаДокумента 		= ТабДанные.Колонки[1].Имя;
	КолонкаКонтрагентНаименование = ТабДанные.Колонки[2].Имя;
	КолонкаКонтрагентИНН 		= ТабДанные.Колонки[3].Имя;
	КолонкаСуммаДокумента 		= ТабДанные.Колонки[4].Имя;
	КолонкаСтавкаНДС 			= ТабДанные.Колонки[5].Имя;
	КолонкаСуммаНДС 			= ТабДанные.Колонки[6].Имя;
	
	Для каждого СтрокаДанных Из ТабДанные Цикл 
		Если (СтрокаДанных.ДатаДокумента = ""
			ИЛИ СтрокаДанных.НомерДокумента = "") Тогда
			
			Продолжить;
		КонецЕсли;
		
		СтрокаТЧ 			= ТаблицаЗагрузки.Добавить();  
		
		СтрокаТЧ.НомерДокумента				= СтрокаДанных[КолонкаНомерДокумента];
		СтрокаТЧ.ДатаДокумента				= СтрВДату(СтрокаДанных[КолонкаДатаДокумента]);
		
		СтрокаТЧ.ИНН 						= СтрокаДанных[КолонкаКонтрагентИНН];
		СтрокаТЧ.НаименованиеСокращенное 	= СтрокаДанных[КолонкаКонтрагентНаименование];
		
		СтрокаТЧ.СуммаДокумента 			= СтрокаДанных[КолонкаСуммаДокумента];
		СтрокаТЧ.СуммаНДС 					= СтрокаДанных[КолонкаСуммаНДС];

		СтрокаТЧ.Контрагент = НайтиКонтрагента(СтрокаДанных[КолонкаКонтрагентИНН], СтрокаДанных[КолонкаКонтрагентНаименование]);
		СтрокаТЧ.Договор 	= НайтиДоговор(СтрокаТЧ.Контрагент, ВидДоговора);
		СтрокаТЧ.СтавкаНДС 	= ПолучитьСтавкуНДС(СтрокаДанных[КолонкаСтавкаНДС]);
		
		Если Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаПокупки Тогда
			СтрокаТЧ.Документ = ПолучитьДокументПоступление(СтрокаТЧ.Контрагент, СтрокаТЧ.НомерДокумента, СтрокаТЧ.ДатаДокумента);
		ИначеЕсли Элементы.Страницы.ТекущаяСтраница = Элементы.СтрницаПродажи Тогда 
			СтрокаТЧ.Документ = ПолучитьДокументРеализации(СтрокаТЧ.Контрагент, СтрокаТЧ.НомерДокумента, СтрокаТЧ.ДатаДокумента);
		КонецЕсли; 	
	КонецЦикла;

КонецПроцедуры
            
&НаСервере
Функция ПолучитьСтавкуНДС(СтрокаСтавкаНДС)
	
	Ставка = ПредопределенноеЗначение("Перечисление.СтавкиНДС.ПустаяСсылка");
	
	Если СтрокаСтавкаНДС = "18%" Тогда
		Ставка = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС18");
	ИначеЕсли СтрокаСтавкаНДС = "18/118" Тогда
		Ставка = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС18_118");
	ИначеЕсли СтрокаСтавкаНДС = "10/110" Тогда
		Ставка = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС10_110");
	ИначеЕсли СтрокаСтавкаНДС = "10%" Тогда
		Ставка = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС10");
	ИначеЕсли СтрокаСтавкаНДС = "0%" Тогда
		Ставка = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС0");
	ИначеЕсли СтрокаСтавкаНДС = "20%" Тогда
		Ставка = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС20");
	ИначеЕсли СтрокаСтавкаНДС = "20/120" Тогда
		Ставка = ПредопределенноеЗначение("Перечисление.СтавкиНДС.НДС20_120");
	ИначеЕсли НРег(СтрокаСтавкаНДС) = "без ндс" Тогда
		Ставка = ПредопределенноеЗначение("Перечисление.СтавкиНДС.БезНДС");
	КонецЕсли;
	
	Возврат Ставка;

КонецФункции 
          
&НаСервере
Функция НайтиКонтрагента(ИНН, Наименование)

    Контрагент = ПредопределенноеЗначение("Справочник.Контрагенты.ПустаяСсылка");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Контрагенты.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Контрагенты КАК Контрагенты
		|ГДЕ
		|	Контрагенты.ИНН = &ИНН
		|	И Контрагенты.НаименованиеПолное = &Наименование";
	
	Запрос.УстановитьПараметр("ИНН", 			ИНН);
	Запрос.УстановитьПараметр("Наименование", 	Наименование);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Выборка.Следующий() Тогда
		
		Контрагент = Выборка.Ссылка;
		
	КонецЕсли;  
	
	Возврат Контрагент;

КонецФункции 

&НаСервере
Функция НайтиДоговор(Контрагент, ВидДоговора)
	
	Договор = ПредопределенноеЗначение("Справочник.ДоговорыКонтрагентов.ПустаяСсылка");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДоговорыКонтрагентов.Ссылка КАК Ссылка,
		|	ДоговорыКонтрагентов.ВидДоговора КАК ВидДоговора
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.Владелец = &Владелец";
	
	Запрос.УстановитьПараметр("Владелец", Контрагент);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Выборка.Количество() = 1 Тогда
		Выборка.Следующий();
		Договор = Выборка.Ссылка;
	Иначе
		Пока Выборка.Следующий() Цикл
			Если Выборка.ВидДоговора = ВидДоговора Тогда	
				Договор = Выборка.Ссылка;	
				Прервать;
			КонецЕсли;	
		КонецЦикла; 
	КонецЕсли;
	
	Возврат Договор;

КонецФункции

&НаСервере
Процедура СоздатьДокументыПокупкиНаСервере()
	
	Для каждого СтрокаТЗ Из Объект.Покупки Цикл
		Если НЕ СтрокаТЗ.Флаг Тогда
			Продолжить;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(СтрокаТЗ.Документ) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Строка не будет обработана, т.к. заполнен документ",,"Объект.Покупки["+(СтрокаТЗ.НомерСтроки-1)+"].Документ");
			Продолжить;			
		КонецЕсли;       
			
		ДокОбъект 							= Документы.ПоступлениеТоваровУслуг.СоздатьДокумент();
		ДокОбъект.Дата						= ТекущаяДата();
		ДокОбъект.НомерВходящегоДокумента  	= СтрокаТЗ.НомерДокумента;
		ДокОбъект.ДатаВходящегоДокумента 	= СтрокаТЗ.ДатаДокумента;
		ДокОбъект.Организация  				= Организация;
		ДокОбъект.Контрагент  				= СтрокаТЗ.Контрагент;
		ДокОбъект.ДоговорКонтрагента		= СтрокаТЗ.Договор;
		ДокОбъект.СуммаВключаетНДС			= Истина; 
		ДокОбъект.Склад						= Склад;
		
		Если ЗначениеЗаполнено(ДокОбъект.ДоговорКонтрагента) Тогда
			ДокОбъект.ВалютаДокумента       = ДокОбъект.ДоговорКонтрагента.ВалютаВзаиморасчетов;
		КонецЕсли;
		
		Если СтрокаТЗ.ПриобретенТовар Тогда
			ДокОбъект.ВидОперации = ПредопределенноеЗначение("Перечисление.ВидыОперацийПоступлениеТоваровУслуг.Товары");
       	Иначе 
			ДокОбъект.ВидОперации = ПредопределенноеЗначение("Перечисление.ВидыОперацийПоступлениеТоваровУслуг.Услуги");
		КонецЕсли;    	
			
		ДанныеОбъекта = Новый Структура(
		"Дата, ВидОперации, Организация, Склад, ТипЦен, СуммаВключаетНДС,
		|ВалютаДокумента, ЕстьРасхождения, РассчитыватьСуммаВРознице, ЗаполнятьСтавкуНДСВРознице,
		|ЭтоКомиссия, ПрименяютсяСтавки4и2, ВедетсяУчетПрослеживаемыхТоваров,            
		|СчетУчетаРасчетовСКонтрагентом, СчетУчетаРасчетовПоАвансам, СпособЗачетаАвансов");
		ЗаполнитьЗначенияСвойств(ДанныеОбъекта, ДокОбъект); 
		
		ДанныеОбъекта.ЭтоКомиссия 					= Ложь;
		ДанныеОбъекта.ЕстьРасхождения 				= Ложь;
		ДанныеОбъекта.РассчитыватьСуммаВРознице 	= Ложь;
		ДанныеОбъекта.ЗаполнятьСтавкуНДСВРознице 	= Ложь;	
		ДанныеОбъекта.ПрименяютсяСтавки4и2 			= Ложь;
		ДанныеОбъекта.ВедетсяУчетПрослеживаемыхТоваров = Ложь;  
		
		ПричиныИзмененияСчетовУчета = Новый Массив;
		ПричиныИзмененияСчетовУчета.Добавить("Контрагент");
		ПричиныИзмененияСчетовУчета.Добавить("ДоговорКонтрагента");	
		
		ПараметрыЗаполнения = ПоступлениеТоваровУслугФормыКлиентСервер.НачатьЗаполнениеСчетовУчета(ПричиныИзмененияСчетовУчета, ДанныеОбъекта);
		СчетаУчетаВДокументах.ЗаполнитьОбъектПриИзменении(ПараметрыЗаполнения);

		ДокОбъект.СчетУчетаРасчетовСКонтрагентом 	= ПараметрыЗаполнения.ДанныеФормы.Объект.СчетУчетаРасчетовСКонтрагентом; 
		ДокОбъект.СчетУчетаРасчетовПоАвансам 		= ПараметрыЗаполнения.ДанныеФормы.Объект.СчетУчетаРасчетовПоАвансам;
		ДокОбъект.СпособЗачетаАвансов 				= ПредопределенноеЗначение("Перечисление.СпособыЗачетаАвансов.Автоматически");
		
		Если СтрокаТЗ.ПриобретенТовар Тогда 
			СтрокаТЧ 					= ДокОбъект.Товары.Добавить();
			СтрокаТЧ.Номенклатура 		= Справочники.Номенклатура.НайтиПоНаименованию("Товар");
			СтрокаТЧ.ЕдиницаИзмерения 	= Справочники.КлассификаторЕдиницИзмерения.НайтиПоНаименованию("Штука");
			СтрокаТЧ.СчетУчетаНДС 		= ПланыСчетов.Хозрасчетный.НДСпоПриобретеннымМПЗ;
			СтрокаТЧ.СпособУчетаНДС 	= Перечисления.СпособыУчетаНДС.ПринимаетсяКВычету;  
			
			ДанныеСтрокиТаблицы = Новый Структура(
			"Номенклатура, ЕдиницаИзмерения, Коэффициент, Количество,
			|Цена, Сумма, СтавкаНДС, СуммаНДС, Всего,
			|НадписьПоДокументу, КоличествоПоДокументу, СуммаПоДокументу, СуммаНДСПоДокументу, ЦенаПоДокументу, ВсегоПоДокументу,
			|НадписьОтклонение, КоличествоОтклонение, СуммаОтклонение,  СуммаНДСОтклонение, ЦенаОтклонение, ВсегоОтклонение, 
			|НадписьПоФакту, НомерГТД, СтранаПроисхождения,
			|ЦенаВРознице, СуммаВРознице, СтавкаНДСВРознице,
			|ОтражениеВУСН, МаркируемаяПродукцияГосИС,
			|ПродукцияМаркируемаяДляГИСМ, ПрослеживаемыйТовар, ПрослеживаемыйКомплект");
			ЗаполнитьЗначенияСвойств(ДанныеСтрокиТаблицы, СтрокаТЧ);
			ДанныеСтрокиТаблицы.ПродукцияМаркируемаяДляГИСМ  = Ложь;
			ДанныеСтрокиТаблицы.ПрослеживаемыйТовар 		= Ложь;
			ДанныеСтрокиТаблицы.ПрослеживаемыйКомплект		= Ложь;
			
			МассивПустыхРеквизитов = Новый Массив;  
			МассивПустыхРеквизитов.Добавить("КоличествоПоДокументу");
			МассивПустыхРеквизитов.Добавить("ЦенаПоДокументу");
			МассивПустыхРеквизитов.Добавить("СуммаПоДокументу");
			МассивПустыхРеквизитов.Добавить("СуммаНДСПоДокументу");
			МассивПустыхРеквизитов.Добавить("ВсегоПоДокументу");
			МассивПустыхРеквизитов.Добавить("Всего");
			
			Для каждого ПустойРеквизит Из МассивПустыхРеквизитов Цикл
				ДанныеСтрокиТаблицы[ПустойРеквизит] = 0;		
			КонецЦикла;
			
			СчетаУчетаКЗаполнению = Новый Соответствие; 
			
			МассивСчетовУчета = Новый Массив;
			МассивСчетовУчета.Добавить("СпособУчетаНДС");
			МассивСчетовУчета.Добавить("СчетУчетаНДС");
			МассивСчетовУчета.Добавить("СчетУчета");
			
			Для каждого ЭлементСчетовУчета Из МассивСчетовУчета Цикл 
				СчетаУчетаКЗаполнению.Вставить("Товары."+ЭлементСчетовУчета, Истина);
				ДанныеСтрокиТаблицы.Вставить(ЭлементСчетовУчета, ПланыСчетов.Хозрасчетный.ПустаяСсылка());	
			КонецЦикла;
									
			ПоступлениеТоваровУслугФормы.ТоварыНоменклатураПриИзменении(ДанныеСтрокиТаблицы, ДанныеОбъекта, СчетаУчетаКЗаполнению);
			
			ЗаполнитьЗначенияСвойств(СтрокаТЧ, ДанныеСтрокиТаблицы);
		Иначе        
			СтрокаТЧ 					= ДокОбъект.Услуги.Добавить();
			СтрокаТЧ.Номенклатура 		= Справочники.Номенклатура.НайтиПоНаименованию("Услуга");
			СтрокаТЧ.СчетУчетаНДС 		= ПланыСчетов.Хозрасчетный.НДСпоПриобретеннымУслугам;
			СтрокаТЧ.СпособУчетаНДС 	= Перечисления.СпособыУчетаНДС.ПринимаетсяКВычету;  
			
			ДанныеСтрокиТаблицы = Новый Структура(
			"Номенклатура, Содержание, Количество, Цена, Сумма, СтавкаНДС, СуммаНДС, ОтражениеВУСН, 
			|НадписьПоДокументу, КоличествоПоДокументу, СуммаПоДокументу, СуммаНДСПоДокументу, ЦенаПоДокументу, ВсегоПоДокументу,
			|НадписьОтклонение, КоличествоОтклонение, СуммаОтклонение, СуммаНДСОтклонение, ЦенаОтклонение, ВсегоОтклонение, НадписьПоФакту");
						
			ЗаполнитьЗначенияСвойств(ДанныеСтрокиТаблицы, СтрокаТЧ); 
			
			МассивПустыхРеквизитов = Новый Массив;  
			МассивПустыхРеквизитов.Добавить("КоличествоПоДокументу");
			МассивПустыхРеквизитов.Добавить("ЦенаПоДокументу");
			МассивПустыхРеквизитов.Добавить("СуммаПоДокументу");
			МассивПустыхРеквизитов.Добавить("СуммаНДСПоДокументу");
			МассивПустыхРеквизитов.Добавить("ВсегоПоДокументу");
			
			Для каждого ПустойРеквизит Из МассивПустыхРеквизитов Цикл
				ДанныеСтрокиТаблицы[ПустойРеквизит] = 0;		
			КонецЦикла;

			СчетаУчетаКЗаполнению = Новый Соответствие;  
			
			МассивСчетовУчета = Новый Массив;
			МассивСчетовУчета.Добавить("СчетЗатрат");
			МассивСчетовУчета.Добавить("Субконто1");
			МассивСчетовУчета.Добавить("Субконто2");
			МассивСчетовУчета.Добавить("Субконто3");
			МассивСчетовУчета.Добавить("СчетЗатратНУ");
			МассивСчетовУчета.Добавить("СубконтоНУ1");
			МассивСчетовУчета.Добавить("СубконтоНУ2");
			МассивСчетовУчета.Добавить("СубконтоНУ3");
			МассивСчетовУчета.Добавить("ПодразделениеЗатрат");
			МассивСчетовУчета.Добавить("СчетУчетаНДС");
			МассивСчетовУчета.Добавить("СпособУчетаНДС");
			
			Для каждого ЭлементСчетовУчета Из МассивСчетовУчета Цикл 
				СчетаУчетаКЗаполнению.Вставить("Услуги."+ЭлементСчетовУчета, Истина);
				ДанныеСтрокиТаблицы.Вставить(ЭлементСчетовУчета, ПланыСчетов.Хозрасчетный.ПустаяСсылка());	
			КонецЦикла;
			
			ПоступлениеТоваровУслугФормы.УслугиНоменклатураПриИзменении(ДанныеСтрокиТаблицы, ДанныеОбъекта, СчетаУчетаКЗаполнению);
			
			ЗаполнитьЗначенияСвойств(СтрокаТЧ, ДанныеСтрокиТаблицы);
		КонецЕсли; 
		
		СтрокаТЧ.Количество 	= 1;
		СтрокаТЧ.Цена 			= СтрокаТЗ.СуммаДокумента;
		СтрокаТЧ.Сумма 			= СтрокаТЗ.СуммаДокумента;
		СтрокаТЧ.СтавкаНДС 		= СтрокаТЗ.СтавкаНДС;  
		СтрокаТЧ.СуммаНДС 		= СтрокаТЗ.СуммаНДС;
		//СтрокаТЧ.Всего          = СтрокаТЗ.СуммаДокумента;
		
		ДокОбъект.Записать();
		
		СтрокаТЗ.Документ = ДокОбъект.Ссылка;
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьДокументыПокупки(Команда)
	СоздатьДокументыПокупкиНаСервере();
КонецПроцедуры

&НаСервере
Процедура СоздатьДокументыПродажиНаСервере()
	
	Для каждого СтрокаТЗ Из Объект.Продажи Цикл
		Если НЕ СтрокаТЗ.Флаг Тогда
			Продолжить;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(СтрокаТЗ.Документ) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Строка не будет обработана, т.к. заполнен документ",,"Объект.Продажи["+(СтрокаТЗ.НомерСтроки-1)+"].Документ");
			Продолжить;			
		КонецЕсли;       
			
		ДокОбъект 							= Документы.РеализацияТоваровУслуг.СоздатьДокумент();
		ДокОбъект.Номер  					= СтрокаТЗ.НомерДокумента;
		ДокОбъект.Дата 						= СтрокаТЗ.ДатаДокумента;
		ДокОбъект.Организация  				= Организация;
		ДокОбъект.Контрагент  				= СтрокаТЗ.Контрагент;
		ДокОбъект.ДоговорКонтрагента   		= СтрокаТЗ.Договор;
		ДокОбъект.СуммаВключаетНДС			= Истина;    
		ДокОбъект.Склад						= Склад;
		
		Если ЗначениеЗаполнено(ДокОбъект.ДоговорКонтрагента) Тогда
			ДокОбъект.ВалютаДокумента       = ДокОбъект.ДоговорКонтрагента.ВалютаВзаиморасчетов;
		КонецЕсли;
		
		Если СтрокаТЗ.ПриобретенТовар Тогда
			ДокОбъект.ВидОперации = ПредопределенноеЗначение("Перечисление.ВидыОперацийРеализацияТоваров.Товары");
		Иначе 
			ДокОбъект.ВидОперации = ПредопределенноеЗначение("Перечисление.ВидыОперацийРеализацияТоваров.Услуги");
		КонецЕсли;	
		
		ДанныеОбъекта = Новый Структура(
		"Дата, ВидОперации, Организация, ДеятельностьНаПатенте,
		|ВалютаДокумента, КурсВзаиморасчетов, КратностьВзаиморасчетов,
		|СуммаВключаетНДС, ДоговорКонтрагента,
		|ЭтоКомиссия, ДокументБезНДС, РеализацияВЕАЭС, 
		|ВедетсяУчетНДСПоФЗ150, ВедетсяУчетНДСПоФЗ335, ПокупательНалоговыйАгентПоНДС, ТипЦен,
		|СчетУчетаРасчетовСКонтрагентом, СчетУчетаРасчетовПоАвансам, СпособЗачетаАвансов, ВедетсяУчетПрослеживаемыхТоваров");
		//ДанныеОбъекта = Новый Структура(
		//"Дата, ВидОперации, Организация, Склад, ТипЦен, СуммаВключаетНДС,
		//|ВалютаДокумента, ЕстьРасхождения, РассчитыватьСуммаВРознице, ЗаполнятьСтавкуНДСВРознице, ЭтоКомиссия, ПрименяютсяСтавки4и2");
		ЗаполнитьЗначенияСвойств(ДанныеОбъекта, ДокОбъект); 
		
		ДанныеОбъекта.ЭтоКомиссия 						= Ложь;
        ДанныеОбъекта.РеализацияВЕАЭС 					= Ложь;
		ДанныеОбъекта.ПокупательНалоговыйАгентПоНДС 	= Ложь;	
		ДанныеОбъекта.ВедетсяУчетПрослеживаемыхТоваров 	= Ложь;
		
		ПричиныИзмененияСчетовУчета = Новый Массив;
		ПричиныИзмененияСчетовУчета.Добавить("Контрагент");
		ПричиныИзмененияСчетовУчета.Добавить("ДоговорКонтрагента");	
		
		ПараметрыЗаполнения = РеализацияТоваровУслугФормыКлиентСервер.НачатьЗаполнениеСчетовУчета(ПричиныИзмененияСчетовУчета, ДанныеОбъекта);
		СчетаУчетаВДокументах.ЗаполнитьОбъектПриИзменении(ПараметрыЗаполнения);

		ДокОбъект.СчетУчетаРасчетовСКонтрагентом 	= ПараметрыЗаполнения.ДанныеФормы.Объект.СчетУчетаРасчетовСКонтрагентом; 
		ДокОбъект.СчетУчетаРасчетовПоАвансам 		= ПараметрыЗаполнения.ДанныеФормы.Объект.СчетУчетаРасчетовПоАвансам;
		ДокОбъект.СпособЗачетаАвансов 				= ПредопределенноеЗначение("Перечисление.СпособыЗачетаАвансов.Автоматически");
		
		Если СтрокаТЗ.ПриобретенТовар Тогда 
			СтрокаТЧ 					= ДокОбъект.Товары.Добавить();
			СтрокаТЧ.Номенклатура 		= Справочники.Номенклатура.НайтиПоНаименованию("Товар");
			СтрокаТЧ.ЕдиницаИзмерения 	= Справочники.КлассификаторЕдиницИзмерения.НайтиПоНаименованию("Штука");
			СтрокаТЧ.СчетУчетаНДСПоРеализации = ПланыСчетов.Хозрасчетный.Продажи_НДС;
			
			ДанныеСтрокиТаблицы = Новый Структура(
			"Номенклатура, ЕдиницаИзмерения, Коэффициент, Количество,
			|Цена, Сумма, СтавкаНДС, СуммаНДС, Всего, 
			|НадписьПоДокументу, КоличествоПоДокументу, СуммаПоДокументу, СуммаНДСПоДокументу, ЦенаПоДокументу, ВсегоПоДокументу,
			|НадписьОтклонение, КоличествоОтклонение, СуммаОтклонение,  СуммаНДСОтклонение, ЦенаОтклонение, ВсегоОтклонение, 
			|НадписьПоФакту, НомерГТД, СтранаПроисхождения,
			|ЦенаВРознице, СуммаВРознице, СтавкаНДСВРознице,
			|ОтражениеВУСН, МаркируемаяПродукцияГосИС,
			|ПродукцияМаркируемаяДляГИСМ, ПрослеживаемыйТовар, ПрослеживаемыйКомплект");    
			
			ЗаполнитьЗначенияСвойств(ДанныеСтрокиТаблицы, СтрокаТЧ);
			ДанныеСтрокиТаблицы.ПродукцияМаркируемаяДляГИСМ  = Ложь;  
			ДанныеСтрокиТаблицы.ПрослеживаемыйТовар 		= Ложь;
			ДанныеСтрокиТаблицы.ПрослеживаемыйКомплект		= Ложь;
			
			МассивПустыхРеквизитов = Новый Массив;  
			МассивПустыхРеквизитов.Добавить("КоличествоПоДокументу");
			МассивПустыхРеквизитов.Добавить("ЦенаПоДокументу");
			МассивПустыхРеквизитов.Добавить("СуммаПоДокументу");
			МассивПустыхРеквизитов.Добавить("СуммаНДСПоДокументу");
			МассивПустыхРеквизитов.Добавить("ВсегоПоДокументу");
			МассивПустыхРеквизитов.Добавить("Всего");
			
			Для каждого ПустойРеквизит Из МассивПустыхРеквизитов Цикл
				ДанныеСтрокиТаблицы[ПустойРеквизит] = 0;		
			КонецЦикла;
				
			СчетаУчетаКЗаполнению = Новый Соответствие; 
			
			МассивСчетовУчета = Новый Массив;
			МассивСчетовУчета.Добавить("СчетРасходов");
			МассивСчетовУчета.Добавить("СчетУчетаНДСПоРеализации");
			МассивСчетовУчета.Добавить("Субконто");
			МассивСчетовУчета.Добавить("СчетДоходов");
			МассивСчетовУчета.Добавить("ПереданныеСчетУчета");
			МассивСчетовУчета.Добавить("СчетУчета");
			
			Для каждого ЭлементСчетовУчета Из МассивСчетовУчета Цикл 
				СчетаУчетаКЗаполнению.Вставить("Товары."+ЭлементСчетовУчета, Истина);
				ДанныеСтрокиТаблицы.Вставить(ЭлементСчетовУчета, ПланыСчетов.Хозрасчетный.ПустаяСсылка());	
			КонецЦикла;
			
			РеализацияТоваровУслугФормы.ТоварыНоменклатураПриИзмененииНаСервере(ДанныеСтрокиТаблицы, ДанныеОбъекта, СчетаУчетаКЗаполнению);
			
			ЗаполнитьЗначенияСвойств(СтрокаТЧ, ДанныеСтрокиТаблицы);
		Иначе        
			СтрокаТЧ 							= ДокОбъект.Услуги.Добавить();
			СтрокаТЧ.Номенклатура 				= Справочники.Номенклатура.НайтиПоНаименованию("Услуга");
			СтрокаТЧ.СчетУчетаНДСПоРеализации 	= ПланыСчетов.Хозрасчетный.Продажи_НДС;
			
			ДанныеСтрокиТаблицы = Новый Структура(
			"Номенклатура, Содержание, Количество, Цена, Сумма, СтавкаНДС, СуммаНДС, ОтражениеВУСН, Всего,  
			|НадписьПоДокументу, КоличествоПоДокументу, СуммаПоДокументу, СуммаНДСПоДокументу, ЦенаПоДокументу, ВсегоПоДокументу,
			|НадписьОтклонение, КоличествоОтклонение, СуммаОтклонение, СуммаНДСОтклонение, ЦенаОтклонение, ВсегоОтклонение, НадписьПоФакту");
			
			ЗаполнитьЗначенияСвойств(ДанныеСтрокиТаблицы, СтрокаТЧ);
			
			МассивПустыхРеквизитов = Новый Массив;  
			МассивПустыхРеквизитов.Добавить("КоличествоПоДокументу");
			МассивПустыхРеквизитов.Добавить("ЦенаПоДокументу");
			МассивПустыхРеквизитов.Добавить("СуммаПоДокументу");
			МассивПустыхРеквизитов.Добавить("СуммаНДСПоДокументу");
			МассивПустыхРеквизитов.Добавить("ВсегоПоДокументу");
			
			Для каждого ПустойРеквизит Из МассивПустыхРеквизитов Цикл
				ДанныеСтрокиТаблицы[ПустойРеквизит] = 0;		
			КонецЦикла;

			СчетаУчетаКЗаполнению = Новый Соответствие;
			
			МассивСчетовУчета = Новый Массив;
			МассивСчетовУчета.Добавить("СчетУчетаНДСПоРеализации");
			МассивСчетовУчета.Добавить("Субконто");
			МассивСчетовУчета.Добавить("СчетРасходов");
			МассивСчетовУчета.Добавить("СчетДоходов");

			Для каждого ЭлементСчетовУчета Из МассивСчетовУчета Цикл 
				СчетаУчетаКЗаполнению.Вставить("Услуги."+ЭлементСчетовУчета, Истина);
				ДанныеСтрокиТаблицы.Вставить(ЭлементСчетовУчета, ПланыСчетов.Хозрасчетный.ПустаяСсылка());	
			КонецЦикла;
						
			РеализацияТоваровУслугФормы.УслугиНоменклатураПриИзмененииНаСервере(ДанныеСтрокиТаблицы, ДанныеОбъекта, СчетаУчетаКЗаполнению);
	
			ЗаполнитьЗначенияСвойств(СтрокаТЧ, ДанныеСтрокиТаблицы);
		КонецЕсли;
		
		СтрокаТЧ.Количество 	= 1;
		СтрокаТЧ.Цена 			= СтрокаТЗ.СуммаДокумента;
		СтрокаТЧ.Сумма 			= СтрокаТЗ.СуммаДокумента;
		СтрокаТЧ.СтавкаНДС 		= СтрокаТЗ.СтавкаНДС;  
		СтрокаТЧ.СуммаНДС 		= СтрокаТЗ.СуммаНДС; 
		
		ДокОбъект.Записать();
		
		СтрокаТЗ.Документ = ДокОбъект.Ссылка;
	КонецЦикла;		

КонецПроцедуры

&НаКлиенте
Процедура СоздатьДокументыПродажи(Команда)
	СоздатьДокументыПродажиНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ФайлПокупкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	
    Диалог.Заголовок 	= "Выберите файл"; 
	Диалог.Фильтр = "Excel файлы(*.xls;*.xlsx)|*.xls;*.xlsx";
	
    Если Диалог.Выбрать() Тогда
        ФайлПокупки 		= Диалог.ПолноеИмяФайла;
		Массив 				= СтрРазделить(Диалог.ПолноеИмяФайла, ".", Ложь); 
		Расширение 			= Массив[Массив.Количество()-1];
    КонецЕсли;  
	
КонецПроцедуры

&НаКлиенте
Процедура ФайлПродажиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)

	Диалог = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	
    Диалог.Заголовок 	= "Выберите файл";
	Диалог.Фильтр = "Excel файлы(*.xls;*.xlsx)|*.xls;*.xlsx";
	
    Если Диалог.Выбрать() Тогда
        ФайлПродажи 		= Диалог.ПолноеИмяФайла;   
		Массив 				= СтрРазделить(Диалог.ПолноеИмяФайла, ".", Ложь); 
		Расширение 			= Массив[Массив.Количество()-1];
	КонецЕсли;

КонецПроцедуры 

// Преобразует строку в дату
// Параметры
//  сДата  – строка
// Возвращаемое значение:
//   дата - тип.дата 
//
Функция СтрВДату(Знач сДата) Экспорт
    
    Перем п_мТЕМП; // массив временных переменных
    
//-----для локализации ------------------------------
    Перем п_мФорматы;
    п_мФорматы = Новый Массив(4);
    п_мФорматы[0] = "г";    // знак года
    п_мФорматы[1] = "ЧЦ=2; ЧН=; ЧВН=";
    п_мФорматы[2] = "ЧГ=0";    
    п_мФорматы[3] = "ДФ=МММ";
//---------------------------------------------------

    Если ПустаяСтрока(сДата) Тогда
        п_мТЕМП[6] =Дата("00010101000000");
        Возврат п_мТЕМП[6];
    КонецЕсли;
    
    сДата = Формат(сДата, п_мФорматы[2]);        //на случай если в формате 1с числом: 20150320220315. (+локализация)
 
 //Если использовать конструкцию "Если Найти(сДата,..." , то перебор букв строки будет происходить 2а раза: Найти и СтрЗаменить //Использование Найти в данном случае бессмысленно
    // можно добавить любой разделитель - @, #, %, и тд, неважно. Главное, заменить их на "."
    сДата = СтрЗаменить(сДата, "«", "");             //«1 Фев 05 г.»
    сДата = СтрЗаменить(сДата, "»", "");            //«1 Фев 05 г.»
     сДата = СтрЗаменить(сДата, п_мФорматы[0] + ".", "");   //1 Фев 05 г. 17:20:00 //просто "г" нельзя из-за "авГуст", например. Но в далее,после парсинга месяца, любое "г" в строке,  удаляется
    сДата = СтрЗаменить(сДата, "/", ".");            // 1/2/5
    сДата = СтрЗаменить(сДата, "\", ".");            // 1\02\05
    сДата = СтрЗаменить(сДата, "-", ".");            // 1-02-05
    сДата = СтрЗаменить(сДата, Символы.Таб, ".");        // 01.02.2005    17:20:00    
    сДата = СтрЗаменить(сДата, " ", ".");            // 1/02 2005 17:20:00
    сДата = СтрЗаменить(сДата, "..",  ".");            //Возможны, появление двойных точек из за "янв." в "янв" или из-за " г. ".    
    сДата = НРег(СокрЛП(сДата));                 // строку в нижний регистр, чтоб проще было с Янв Январь янв и тд
    
    п_мТЕМП = Новый массив(7);//массив для временных переменных    
    
    п_мТЕМП[0] = Найти(сДата,".");
    
    Если п_мТЕМП[0] = 0 Тогда
        //если точек нет
        
        Если Найти(сДата,":") Тогда
                //только время (или ошибка)
                сДата = "01.01.0001." + сДата;
                п_мТЕМП[0] = Найти(сДата,".");
        иначе            
                //похоже на формат 1с. Можно добавить "попытку"...
                п_мТЕМП[6] = дата(сДата);
                Возврат п_мТЕМП[6];

        КонецЕсли;    
        
        
    //иначеЕсли п_мТЕМП[0] = 1 Тогда
    //        //например, месяц и год
    КонецЕсли;
    

    // ----- ДНИ -------------------------------------
    п_мТЕМП[0] = Лев(сДата, п_мТЕМП[0] - 1);//дни 
    п_мТЕМП[4] = Прав(сДата, СтрДлина(сДата) - СтрДлина(п_мТЕМП[0])-1);// месяц и все что справа
    п_мТЕМП[0] = Формат(Число(п_мТЕМП[0]),п_мФорматы[1]);//дни в формат двух чисел
    // ----- Месяц -----------------------------------
    п_мТЕМП[1] = Лев(п_мТЕМП[4], найти(п_мТЕМП[4],".") - 1);// месяц
    п_мТЕМП[4] = Прав(п_мТЕМП[4], СтрДлина(п_мТЕМП[4]) - СтрДлина(п_мТЕМП[1])-1);// год и все что справа
    //Возможны варианты месяца "янв" "янв." "январь" "января" 
    Если СтрДлина(п_мТЕМП[1]) > 2 Тогда // месяц в виде янв или январь
        
        п_мТЕМП[2] = 0;
        Пока п_мТЕМП[2] < 12 Цикл 
            
            п_мТЕМП[2] = п_мТЕМП[2]+1;
            // берем из "янв." только "янв"
            п_мТЕМП[3] = СтрЗаменить(Формат(Дата("2001" + Формат(п_мТЕМП[2],п_мФорматы[1]) + "01"), п_мФорматы[3]),".","");// + локализация
            
            п_мТЕМП[3] = найти(п_мТЕМП[1], п_мТЕМП[3]);
            
            Если п_мТЕМП[3] > 0 тогда
                п_мТЕМП[1] = Формат(п_мТЕМП[2],п_мФорматы[1]);
                прервать;
            КонецЕсли;
        КонецЦикла;    
    Иначе
        п_мТЕМП[1] = Формат(Число(п_мТЕМП[1]),п_мФорматы[1]);
    КонецЕсли;
    // ----- ГОД -----------------------------------
    //Если в строке было "г" без точки("г.")
    п_мТЕМП[4] = СтрЗаменить(п_мТЕМП[4], п_мФорматы[0], "");
    //ищем год. Дата может быть без времени, т.е. год последний в строке
    п_мТЕМП[2] = Найти(п_мТЕМП[4],".");
    
    Если п_мТЕМП[2]>0 Тогда
        п_мТЕМП[2] =  Лев(п_мТЕМП[4], п_мТЕМП[2] - 1);// год
        п_мТЕМП[4] = Прав(п_мТЕМП[4], СтрДлина(п_мТЕМП[4]) - СтрДлина(п_мТЕМП[2])-1);//время и все что справа
    Иначе
        п_мТЕМП[2] = п_мТЕМП[4];
        п_мТЕМП[4] = "";
    КонецЕсли;    
    
    //проверяем год
    п_мТЕМП[3] = СтрДлина(п_мТЕМП[2]);
    //если год из двух цыфр
    Если п_мТЕМП[3] = 2 или п_мТЕМП[3] = 1 Тогда
        п_мТЕМП[3] = Число(п_мТЕМП[2]);// год как число
        
        //что означает 15 в "20.03.15"? это 2015г или 1915г? (Настраиваем под себя или выдаём ошибку)
        // в моем варианте если  < 50 то это 2000г. иначе 1900г.
        Если п_мТЕМП[3] < 50 Тогда 
            п_мТЕМП[2] = "20" + Формат(п_мТЕМП[3],п_мФорматы[1]);
        Иначе
            п_мТЕМП[2] = "19" + Формат(п_мТЕМП[3],п_мФорматы[1]);
        КонецЕсли;    
        
    КонецЕсли;
 
    // =======================  Форматируем время ==============================
    п_мТЕМП[6] = СтрЗаменить(п_мТЕМП[4],":", ".");// если дата была, например: 17-30-10, то сейчас 17.30.10 
    //"попытка" на преобразование даты, по времени, занимает столько же, а по ресурсам больше, чем сам парсинг времени. 
    //поэтому, убиваем двух зайцев перебором часы/мин/сек сразу
    Если СтрДлина(п_мТЕМП[6]) > 0 Тогда
        
        п_мТЕМП[5] = найти(п_мТЕМП[6],".");
        Если п_мТЕМП[5] > 0 Тогда
            // ========= часы    =================
            п_мТЕМП[3] = Лев(п_мТЕМП[6], найти(п_мТЕМП[6],".") - 1);//часы 
            п_мТЕМП[6] = Прав(п_мТЕМП[6], СтрДлина(п_мТЕМП[6]) - СтрДлина(п_мТЕМП[3])-1);// минуты и все что справа
            
            Если п_мТЕМП[3] = "" тогда
                п_мТЕМП[3] = "00";        
            Иначе
                //при переводе в дату лидирующий 0 у часов удаляется. Т.е. след. строка бесполезна
                //п_мТЕМП[3] = Формат(Число(п_мТЕМП[3]),п_мФорматы[1]);//часы в формат двух чисел     
            КонецЕсли;        
            
            п_мТЕМП[5] = найти(п_мТЕМП[6],".");
            Если п_мТЕМП[5] > 0 Тогда
                // ========= минуты    =================
                п_мТЕМП[4] = Лев(п_мТЕМП[6], найти(п_мТЕМП[6],".") - 1);
                п_мТЕМП[6] = Прав(п_мТЕМП[6], СтрДлина(п_мТЕМП[6]) - СтрДлина(п_мТЕМП[4])-1);// секунды и все что справа
                Если п_мТЕМП[4] = "" тогда
                    п_мТЕМП[4] = "00";        
                Иначе
                    п_мТЕМП[4] = Формат(Число(п_мТЕМП[4]),п_мФорматы[1]);//минуты в формат двух чисел     
                КонецЕсли;
                
                // ========= секунды    =================
                Если СтрДлина(п_мТЕМП[6]) = 0 Тогда
                    п_мТЕМП[5] = "00";        
                Иначе
                    п_мТЕМП[5] = Формат(Число(п_мТЕМП[6]),п_мФорматы[1]);//секунды в формат двух чисел     
                КонецЕсли;
                
            Иначе
                п_мТЕМП[4] = Формат(Число(п_мТЕМП[6]),п_мФорматы[1]);    
                п_мТЕМП[5] = "00";            
            КонецЕсли;     
        Иначе
            п_мТЕМП[3] = Формат(Число(п_мТЕМП[6]),п_мФорматы[1]);        
            п_мТЕМП[4] = "00";
            п_мТЕМП[5] = "00";
        КонецЕсли;
        
    Иначе
        п_мТЕМП[3] = "00";        
        п_мТЕМП[4] = "00";
        п_мТЕМП[5] = "00";            
    КонецЕсли;
    
    п_мТЕМП[6] = п_мТЕМП[0] + "." + п_мТЕМП[1] + "." + п_мТЕМП[2] + " " + п_мТЕМП[3] + ":" + п_мТЕМП[4] + ":" + п_мТЕМП[5];
    п_мТЕМП[6] = дата(п_мТЕМП[6]);
    
    Возврат п_мТЕМП[6];
     
КонецФункции

&НаКлиенте
Процедура УстановитьВсе(Команда)
	
	УстановитьФлажки(Истина);

КонецПроцедуры

&НаКлиенте
Процедура СнятьВсе(Команда)
	
	УстановитьФлажки(Ложь);

КонецПроцедуры

&НаКлиенте
Процедура УстановитьФлажки(Флаг)

	Если Элементы.Страницы.ТекущаяСтраница = Элементы.СтраницаПокупки Тогда
		Для каждого СтрокаТЧ Из Объект.Покупки Цикл
			СтрокаТЧ.Флаг = Флаг;	
		КонецЦикла;
	ИначеЕсли Элементы.Страницы.ТекущаяСтраница = Элементы.СтрницаПродажи Тогда
		Для каждого СтрокаТЧ Из Объект.Продажи Цикл
			СтрокаТЧ.Флаг = Флаг;	
		КонецЦикла;	
	КонецЕсли;

КонецПроцедуры  

&НаСервере
Функция ПолучитьДокументПоступление(Контрагент, НомерВходящегоДокумента, ДатаВходящегоДокумента)
	
	Ссылка = ПредопределенноеЗначение("Документ.ПоступлениеТоваровУслуг.ПустаяСсылка");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	ПоступлениеТоваровУслуг.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.ПоступлениеТоваровУслуг КАК ПоступлениеТоваровУслуг
		|ГДЕ
		|	ПоступлениеТоваровУслуг.Контрагент = &Контрагент
		|	И ПоступлениеТоваровУслуг.ДатаВходящегоДокумента = &ДатаВходящегоДокумента
		|	И ПоступлениеТоваровУслуг.НомерВходящегоДокумента = &НомерВходящегоДокумента
		|	И НЕ ПоступлениеТоваровУслуг.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("ДатаВходящегоДокумента", 	ДатаВходящегоДокумента);
	Запрос.УстановитьПараметр("Контрагент", 				Контрагент);
	Запрос.УстановитьПараметр("НомерВходящегоДокумента", 	НомерВходящегоДокумента);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Выборка.Следующий() Тогда

		Ссылка = Выборка.Ссылка;		
		
	КонецЕсли;
	
	Возврат Ссылка;

КонецФункции

&НаСервере
Функция ПолучитьДокументРеализации(Контрагент, Номер, Дата)
	
	Ссылка = ПредопределенноеЗначение("Документ.РеализацияТоваровУслуг.ПустаяСсылка");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	РеализацияТоваровУслуг.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
		|ГДЕ
		|	РеализацияТоваровУслуг.Контрагент = &Контрагент
		|	И РеализацияТоваровУслуг.Дата = &Дата
		|	И РеализацияТоваровУслуг.Номер = &Номер
		|	И НЕ РеализацияТоваровУслуг.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("Дата", 			Дата);
	Запрос.УстановитьПараметр("Контрагент", 	Контрагент);
	Запрос.УстановитьПараметр("Номер", 			Номер);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Выборка.Следующий() Тогда

		Ссылка = Выборка.Ссылка;		
		
	КонецЕсли;
	
	Возврат Ссылка;

КонецФункции


