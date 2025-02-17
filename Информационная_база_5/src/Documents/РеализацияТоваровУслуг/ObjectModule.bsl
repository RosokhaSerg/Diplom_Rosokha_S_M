
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Ответственный = Пользователи.ТекущийПользователь();
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказПокупателя") Тогда
		ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.ОбработкаЗаказов.Записывать = Истина;
	Движения.ОстаткиТоваров.Записывать = Истина;
	
	Движение = Движения.ОбработкаЗаказов.Добавить();
	Движение.Период = Дата;
	Движение.Контрагент = Контрагент;
	Движение.Договор = Договор;
	Движение.Заказ = Основание;
	Движение.СуммаОтгрузки = СуммаДокумента;
	Движение.ВКМ_СтоимостьУслуг = Услуги.Итог("Сумма");
	

	Для Каждого ТекСтрокаТовары Из Товары Цикл
		Движение = Движения.ОстаткиТоваров.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
		Движение.Сумма = ТекСтрокаТовары.Сумма;
		Движение.Количество = ТекСтрокаТовары.Количество;
	КонецЦикла;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЗаказПокупателя.Организация КАК Организация,
	               |	ЗаказПокупателя.Контрагент КАК Контрагент,
	               |	ЗаказПокупателя.Договор КАК Договор,
	               |	ЗаказПокупателя.СуммаДокумента КАК СуммаДокумента,
	               |	ЗаказПокупателя.Товары.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Товары,
	               |	ЗаказПокупателя.Услуги.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Услуги
	               |ИЗ
	               |	Документ.ЗаказПокупателя КАК ЗаказПокупателя
	               |ГДЕ
	               |	ЗаказПокупателя.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Не Выборка.Следующий() Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Выборка);
	
	ТоварыОснования = Выборка.Товары.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Товары.Добавить(), ТоварыОснования);
	КонецЦикла;
	
	УслугиОснования = Выборка.Услуги.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Услуги.Добавить(), УслугиОснования);
	КонецЦикла;
	
	Основание = ДанныеЗаполнения;
	
КонецПроцедуры

//--Росоха С.

Процедура ВКМ_Автозаполнение(Договор) Экспорт

	АбонентскаяПлатаКонст = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить(); 
	РаботаСпециалистаКонст = Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить();
	АбоненткаяПлатаПоДоговору = Договор.ВКМ_АбонентскаяПлата; 
	
	Если Не ЗначениеЗаполнено(АбонентскаяПлатаКонст) 
		ИЛИ Не ЗначениеЗаполнено(РаботаСпециалистаКонст) Тогда 
		ОбщегоНазначения.СообщитьПользователю("Вид работ не установлен");
		Возврат;
	КонецЕсли;  
	
	ЭтотОбъект.Услуги.Очистить();
	
	Если Не АбоненткаяПлатаПоДоговору = 0  Тогда
	   	ТабЧастьУслуги = ЭтотОбъект.Услуги.Добавить();
		ТабЧастьУслуги.Номенклатура = АбонентскаяПлатаКонст;
		ТабЧастьУслуги.Количество = 1;
		ТабЧастьУслуги.Цена = АбоненткаяПлатаПоДоговору;
		ТабЧастьУслуги.Сумма = АбоненткаяПлатаПоДоговору;   
    КонецЕсли; 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВКМ_ВыполненныеКлиентуРаботыОбороты.КоличествоЧасовОборот КАК КоличествоЧасов,
	|	ВКМ_ВыполненныеКлиентуРаботыОбороты.СуммаКОплатеОборот КАК СуммаКОплате
	|ИЗ
	|	РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы.Обороты(&НачалоПериода, &КонецПериода, Месяц, Договор.Ссылка = &Ссылка) КАК ВКМ_ВыполненныеКлиентуРаботыОбороты"; 
	
	Запрос.УстановитьПараметр("Ссылка", Договор);
	Запрос.УстановитьПараметр("НачалоПериода", НачалоМесяца(Дата));
	Запрос.УстановитьПараметр("КонецПериода", КонецМесяца(Дата)); 
	
	Результат = Запрос.Выполнить();	
	Выборка = Результат.Выбрать();
	
	Пока Выборка.Следующий() Цикл    
		
		ТабЧастьУслуги = ЭтотОбъект.Услуги.Добавить();
		ТабЧастьУслуги.Номенклатура = РаботаСпециалистаКонст;   
		
		ТабЧастьУслуги.Количество = Выборка.КоличествоЧасов;
		ТабЧастьУслуги.Цена = Выборка.СуммаКОплате/Выборка.КоличествоЧасов;
		ТабЧастьУслуги.Сумма = Выборка.СуммаКОплате;
	КонецЦикла;    
	
	СуммаДокумента =  Услуги.Итог("Сумма");
	
КонецПроцедуры 

//--Росоха С.

#КонецОбласти

#КонецЕсли
