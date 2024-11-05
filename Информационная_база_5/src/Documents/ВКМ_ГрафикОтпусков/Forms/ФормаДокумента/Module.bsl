
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)    
     ПроверитьПревышениеПоОтпускам(Объект); 
КонецПроцедуры   

 &НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
   ПроверитьПревышениеПоОтпускам(ТекущийОбъект); 
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормы

&НаКлиенте
Процедура ОтпускаСотрудниковДатаНачалаПриИзменении(Элемент)
     
    ТекДанные = Элементы.ОтпускаСотрудников.ТекущиеДанные; 
    Если ЗначениеЗаполнено(ТекДанные.ДатаНачала) и ЗначениеЗаполнено(ТекДанные.ДатаОкончания) Тогда
        Если ТекДанные.ДатаНачала > ТекДанные.ДатаОкончания Тогда
            Сообщить("Дата начала не может быть больше даты окончания"); 
            ТекДанные.ДатаНачала = ""; 
        КонецЕсли; 
    КонецЕсли;  
    
    МассивСотрудников = ПолучитьСотрудниковПревышениеОтпуска(Объект);   
    
    Если ЗначениеЗаполнено(ТекДанные.ДатаНачала) и ЗначениеЗаполнено(ТекДанные.ДатаОкончания) Тогда
        Если  ЗначениеЗаполнено(МассивСотрудников) Тогда
            Сообщить("Подсвеченные сотрудники имеют превышение по отпуску"); 
            УстановитьПодсветкуСтрок(МассивСотрудников); 
        Иначе 
            ОтменитьПодсветкуСтрок(); 
        КонецЕсли;  
    КонецЕсли; 
    
КонецПроцедуры 

&НаКлиенте
Процедура ОтпускаСотрудниковДатаОкончанияПриИзменении(Элемент)
     
    ТекДанные = Элементы.ОтпускаСотрудников.ТекущиеДанные;  
    Если ЗначениеЗаполнено(ТекДанные.ДатаНачала) и ЗначениеЗаполнено(ТекДанные.ДатаОкончания) Тогда
        Если ТекДанные.ДатаНачала > ТекДанные.ДатаОкончания Тогда
            Сообщить("Дата окончания не может быть меньше даты начала"); 
            ТекДанные.ДатаОкончания = ""; 
        КонецЕсли; 
    КонецЕсли; 
    
    МассивСотрудников = ПолучитьСотрудниковПревышениеОтпуска(Объект); 
    
    Если ЗначениеЗаполнено(ТекДанные.ДатаНачала) и ЗначениеЗаполнено(ТекДанные.ДатаОкончания) Тогда
        Если  ЗначениеЗаполнено(МассивСотрудников) Тогда
            Сообщить("Подсвеченные сотрудники имеют превышение по отпуску"); 
            УстановитьПодсветкуСтрок(МассивСотрудников); 
        Иначе 
            ОтменитьПодсветкуСтрок(); 
        КонецЕсли;
    КонецЕсли; 
    
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ПроверитьПревышениеПоОтпускам(Объект)   
    
     МассивСотрудников = ПолучитьСотрудниковПревышениеОтпуска(Объект);
     Если  ЗначениеЗаполнено(МассивСотрудников) Тогда
         Сообщить("Подсвеченные сотрудники имеют превышение по отпуску или неккоректно указан период"); 
         УстановитьПодсветкуСтрок(МассивСотрудников); 
      Иначе 
         ОтменитьПодсветкуСтрок(); 
     КонецЕсли;      
          
КонецПроцедуры

&НаСервере
Функция ПолучитьСотрудниковПревышениеОтпуска(Знач Объект)

	МассивСотрудников = Новый Массив; 
    СотрудникиТЧ = Объект.ОтпускаСотрудников.Выгрузить(); 
    СотрудникиТЧ.Колонки.Добавить("СуммаДней", Новый ОписаниеТипов("Число")); 
    Для каждого Строка Из СотрудникиТЧ Цикл 
         СрокОтпуска = Строка.ДатаОкончания - Строка.ДатаНачала; 
    	 Строка.СуммаДней = СрокОтпуска / 86400 + 1; 
    КонецЦикла;    
     
    СотрудникиТЧ.Свернуть("Сотрудник", "СуммаДней"); 
    
    Для каждого Строка  Из СотрудникиТЧ Цикл
       Если Строка.СуммаДней > 28 ИЛИ Строка.СуммаДней < 0 Тогда
          МассивСотрудников.Добавить(Строка.Сотрудник); 
       КонецЕсли;
   КонецЦикла;
   
   Возврат МассивСотрудников; 

КонецФункции // ()  

&НаСервере
Процедура УстановитьПодсветкуСтрок(МассивСотрудников)
   УсловноеОформление.Элементы.Очистить();
   
   Для каждого Элемент Из МассивСотрудников Цикл
        ЭлементОформления = УсловноеОформление.Элементы.Добавить(); 
        ЭлементОформления.Использование = Истина; 
        ЭлементОформления.Оформление.УстановитьЗначениеПараметра("ЦветФона", Новый Цвет (200,0,0)); 
        
        ЭлементУсловия = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных")); 
        ЭлементУсловия.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.ОтпускаСотрудников.Сотрудник"); 
        ЭлементУсловия.ПравоеЗначение = Элемент; 
        ЭлементУсловия.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно; 
        ЭлементУсловия.Использование = Истина; 
        
        ОформляемоеПоле = ЭлементОформления.Поля.Элементы.Добавить(); 
        ОформляемоеПоле.Поле = Новый ПолеКомпоновкиДанных("ОтпускаСотрудниковСотрудник"); 
        
   КонецЦикла;
	

КонецПроцедуры

&НаСервере
Процедура ОтменитьПодсветкуСтрок()

	УсловноеОформление.Элементы.Очистить();

КонецПроцедуры

&НаКлиенте
Процедура АнализГрафика(Команда)
    ОткрытьФорму("Документ.ВКМ_ГрафикОтпусков.Форма.АнализГрафика",,ЭтаФорма); 
КонецПроцедуры   

&НаСервере
Функция ПоместитьВоВременноеХранилищеНаСервере() Экспорт

	 ОтпускаСотрудниковДанные = Новый Массив; 
     
     Для каждого Строка Из Объект.ОтпускаСотрудников Цикл
         СотрудникСтруктура = Новый Структура("Имя, Начало, Конец", 
            Строка.Сотрудник, Строка.ДатаНачала, Строка.ДатаОкончания); 
         ОтпускаСотрудниковДанные.Добавить(СотрудникСтруктура); 
     КонецЦикла;  
     
     Адрес = ПоместитьВоВременноеХранилище(ОтпускаСотрудниковДанные, Новый УникальныйИдентификатор); 
     Возврат Адрес; 
     
 КонецФункции // ()   
 

#КонецОбласти





