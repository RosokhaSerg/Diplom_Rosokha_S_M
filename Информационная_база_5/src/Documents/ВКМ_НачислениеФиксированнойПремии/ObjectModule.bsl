  
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда  

#Область ОбработчикиСобытийМодуляОбъекта
    
Процедура ОбработкаПроведения(Отказ, Режим)
	
	// регистр ВКМ_ДополнительныеНачисления
	Движения.ВКМ_ДополнительныеНачисления.Записывать = Истина;
	Для Каждого ТекСтрокаСотрудники Из СписокСотрудников Цикл
		Движение = Движения.ВКМ_ДополнительныеНачисления.Добавить();
		Движение.Сторно = Ложь;
		Движение.ПериодРегистрации = Дата;
		Движение.Сотрудник = ТекСтрокаСотрудники.Сотрудник;
		Движение.Подразделение = Подразделение;   
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_ДополнительныеНачисления.Премия; 
		Движение.Сумма = ТекСтрокаСотрудники.СуммаПремии;   
	КонецЦикла;   
	
	Движения.ВКМ_ДополнительныеНачисления.Записать(); 
	
	Движения.ВКМ_Удержания.Записывать = Истина;   
	
	РасчетУдержаний(); 
	
	СформироватьДвиженияВзаиморасчетыССотрудниками(); 

КонецПроцедуры     

#КонецОбласти  

#Область СлужебныеПроцедурыФункции

Процедура РасчетУдержаний()

	Запрос = Новый Запрос;
	Запрос.Текст = 
	  "ВЫБРАТЬ РАЗЛИЧНЫЕ
	  |	ВКМ_НачислениеФиксированнойПремииСотрудники.Сотрудник КАК Сотрудник
	  |ИЗ
	  |	Документ.ВКМ_НачислениеФиксированнойПремии.СписокСотрудников КАК ВКМ_НачислениеФиксированнойПремииСотрудники
	  |ГДЕ
	  |	ВКМ_НачислениеФиксированнойПремииСотрудники.Ссылка = &Ссылка";
	 
	Запрос.УстановитьПараметр("Ссылка", Ссылка);

	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ВКМ_Удержания.Добавить();
		Движение.ПериодРегистрации = Дата;
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ;
		Движение.Сотрудник = Выборка.Сотрудник;  
		Движение.Подразделение = Подразделение; 
		Движение.БазовыйПериодНачало = НачалоМесяца(Дата);
		Движение.БазовыйПериодКонец = КонецМесяца(Дата);
	КонецЦикла;   
	
	Движения.ВКМ_Удержания.Записать();   
	
	РасчетСуммыУдержаний(); 
		    
КонецПроцедуры

Процедура РасчетСуммыУдержаний()

	Запрос = Новый Запрос; 
	Запрос.Текст = "
      | ВЫБРАТЬ
	  |	ВКМ_Удержания.НомерСтроки КАК НомерСтроки,
	  |	ЕСТЬNULL(ВКМ_УдержанияБазаВКМ_ДополнительныеНачисления.СуммаБаза, 0) КАК СуммаБаза
	  |ИЗ
	  |	РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
	  |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_Удержания.БазаВКМ_ДополнительныеНачисления(
	  |				&Измерения,
	  |				&Измерения,
	  |				,
	  |				Регистратор = &Ссылка
	  |					И ВидРасчета = &ВидРасчета) КАК ВКМ_УдержанияБазаВКМ_ДополнительныеНачисления
	  |		ПО ВКМ_Удержания.НомерСтроки = ВКМ_УдержанияБазаВКМ_ДополнительныеНачисления.НомерСтроки
	  |ГДЕ
	  |	ВКМ_Удержания.Регистратор = &Ссылка";
	
	Измерение = Новый Массив; 
	Измерение.Добавить("Сотрудник");  
	Измерение.Добавить("Подразделение"); 

	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Измерения", Измерение); 
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ВКМ_Удержания.НДФЛ); 

	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();  
	
	Пока Выборка.Следующий() Цикл   
		Движение = Движения.ВКМ_Удержания[Выборка.НомерСтроки - 1]; 
		Движение.Сумма = Выборка.СуммаБаза * 13 / 100; 
    КонецЦикла;
    
    Движения.ВКМ_Удержания.Записать(,Истина); 

КонецПроцедуры

Процедура СформироватьДвиженияВзаиморасчетыССотрудниками()

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_Удержания.Сумма КАК НДФЛ,
		|	ВКМ_ДополнительныеНачисления.Сотрудник КАК Сотрудник,
		|	СУММА(ВКМ_ДополнительныеНачисления.Сумма) КАК Сумма
		|ИЗ
		|	РегистрРасчета.ВКМ_ДополнительныеНачисления КАК ВКМ_ДополнительныеНачисления
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
		|		ПО ВКМ_ДополнительныеНачисления.Сотрудник = ВКМ_Удержания.Сотрудник
		|ГДЕ
		|	ВКМ_Удержания.Регистратор = &Ссылка
		|	И ВКМ_ДополнительныеНачисления.Регистратор = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	ВКМ_ДополнительныеНачисления.Сотрудник,
		|	ВКМ_Удержания.Сумма
		|ИТОГИ
		|	СУММА(НДФЛ),
		|	СУММА(Сумма)
		|ПО
		|	Сотрудник";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Сотрудник");
	
	Пока Выборка.Следующий() Цикл   
		Если Выборка.Сумма <> 0 Тогда
		Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить(); 
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход; 
		Движение.Период = Дата; 
		Движение.Подразделение = Подразделение; 
		Движение.Сотрудник = Выборка.Сотрудник; 
		Движение.Сумма = Выборка.Сумма - Выборка.НДФЛ; 
		КонецЕсли; 
	КонецЦикла;
	
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать(); 

КонецПроцедуры

#КонецОбласти

#КонецЕсли
