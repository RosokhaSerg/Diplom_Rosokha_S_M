#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура Заполнить(Команда)
    
    //использование механизма длительных операций БСП,
    ДлительнаяОперация = НачатьВыполнениеНаСервере(); 
    ОповещениеОЗавершении = Новый ОписаниеОповещения("ОбработатьРезультат", ЭтотОбъект); 
    ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект); 
    ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания); 
    
КонецПроцедуры

&НаСервере
Функция НачатьВыполнениеНаСервере()

	 ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияФункции(УникальныйИдентификатор);
     Возврат ДлительныеОперации.ВыполнитьФункцию(ПараметрыВыполнения,"Обработки.ВКМ_МассовоеСозданиеАктов.СоздатьСписокНаСервере",
        Объект.Период.ДатаНачала, Объект.Период.ДатаОкончания); 

КонецФункции // ()  
    
&НаКлиенте
Процедура ОбработатьРезультат(Результат, ДополнительныеПараметры) Экспорт

	Если Результат = Неопределено Тогда
    
    	Возврат; 
    
    КонецЕсли;   
    
    СписокРеализацийМассив = ПолучитьИзВременногоХранилища(Результат.АдресРезультата); 
    ЗаполнитьСписокРеализаций(СписокРеализацийМассив); 

КонецПроцедуры  

&НаКлиенте
Процедура  ЗаполнитьСписокРеализаций(СписокРеализацийМассив) 
	
	Если СписокРеализацийМассив = Неопределено Тогда  
		
		Список = НовыйСоздатьСписокНаСервере();  
		Объект.СписокРеализаций.Очистить();
		Для каждого Строка Из Список Цикл
			
			НоваяСтрока = Объект.СписокРеализаций.Добавить(); 
			НоваяСтрока.Договор = Строка.Договор; 
			НоваяСтрока.Реализация = Строка.Реализация; 
			
		КонецЦикла;  
	Иначе
		Для каждого Строка Из СписокРеализацийМассив Цикл
			
			НоваяСтрока = Объект.СписокРеализаций.Добавить(); 
			НоваяСтрока.Договор = Строка.Договор; 
			НоваяСтрока.Реализация = Строка.Реализация; 
			
		КонецЦикла;  


	КонецЕсли;
	
     
     
     
 КонецПроцедуры    
 
Функция НовыйСоздатьСписокНаСервере()
	
	ДатаНачала = Объект.Период.ДатаНачала;
	ДатаОкончания = Объект.Период.ДатаОкончания;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РеализацияТоваровУслуг.Ссылка КАК Ссылка
	|ПОМЕСТИТЬ ВТ_Реализации
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	|ГДЕ
	|	РеализацияТоваровУслуг.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Ссылка КАК Договор,
	|	ВТ_Реализации.Ссылка КАК Реализация
	|ИЗ
	|	ВТ_Реализации КАК ВТ_Реализации
	|		ПРАВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|		ПО (ДоговорыКонтрагентов.Ссылка = ВТ_Реализации.Ссылка.Договор)
	|ГДЕ
	|	ДоговорыКонтрагентов.ВидДоговора = ЗНАЧЕНИЕ(Перечисление.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание)
	|	И ДоговорыКонтрагентов.ВКМ_ПериодС < &ДатаНачала
	|	И ДоговорыКонтрагентов.ВКМ_По > &ДатаОкончания"; 
   	
	Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", ДатаОкончания);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();  
	
	СписокРеализацийМассив = Новый Массив;
	
	Пока Выборка.Следующий() Цикл
		СписокРеализацийСтруктура = Новый Структура; 
        Если Не ЗначениеЗаполнено(Выборка.Реализация) Тогда  
         	НоваяРеализация = СоздатьНовуюРеализацию(Выборка.Договор, ДатаОкончания); 
			СписокРеализацийСтруктура.Вставить("Договор", Выборка.Договор); 
			СписокРеализацийСтруктура.Вставить("Реализация", НоваяРеализация);
        Иначе 
			СписокРеализацийСтруктура.Вставить("Договор", Выборка.Договор); 
			СписокРеализацийСтруктура.Вставить("Реализация", Выборка.Реализация);	
		КонецЕсли; 
		СписокРеализацийМассив.Добавить(СписокРеализацийСтруктура); 
	КонецЦикла; 
	
	Возврат СписокРеализацийМассив; 
	
КонецФункции 

Функция СоздатьНовуюРеализацию(Договор, ДатаСозданияНовойРеализации)
	
	НоваяРеализация = Документы.РеализацияТоваровУслуг.СоздатьДокумент(); 
	НоваяРеализация.Заполнить(Договор.Ссылка); 
	НоваяРеализация.Дата = ДатаСозданияНовойРеализации; 
	НоваяРеализация.Ответственный = Пользователи.ТекущийПользователь(); 
	НоваяРеализация.Договор = Договор; 
	НоваяРеализация.Контрагент = Договор.Владелец; 
	НоваяРеализация.Организация = Договор.Организация;    
	
	НачатьТранзакцию(); 
	
	Если ЗначениеЗаполнено(НоваяРеализация.Договор) Тогда
		Попытка
			НоваяРеализация.Записать(РежимЗаписиДокумента.Проведение,РежимПроведенияДокумента.Неоперативный); 
        	ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			Сообщить("Не удалось провести документ"); 
			ЗаписьЖурналаРегистрации("ОБРАБОТКА: Массовое создание актов. Отмена проведения"); 
		КонецПопытки;
	Иначе 
		Сообщить(СтрШаблон("Не удалось создать реализацию по Договору: %1. Не все обязательные данные заполнены", Договор)); 
	КонецЕсли;
	
	Возврат НоваяРеализация.Ссылка;    
	
КонецФункции // ()


#КонецОбласти
