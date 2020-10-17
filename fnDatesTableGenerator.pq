let Source = 
 let 
 YearStart = DateTime.Date(Date.StartOfYear(DateTime.FixedLocalNow())),
 YearEnd = DateTime.Date(Date.EndOfYear(DateTime.FixedLocalNow())),
 tp = type function (StartDate as (type date  meta
            [
                Documentation.DefaultValue = {YearStart},
                Documentation.FieldCaption = "Start Date",
                Documentation.FieldDescription = "Earliest date in date range"
            ])
            ,EndDate as (type date  meta
            [
                Documentation.DefaultValue = {YearEnd},
                Documentation.FieldCaption = "End Date",
                Documentation.FieldDescription = "Latest date in date range"
            ])
            ) as table meta 
            [
              Documentation.Name = "Dates Generator",
              Documentation.LongDescription = "Generate dates tables for your data tables"
            ]

,fn = (StartDate as date, EndDate as date) =>
  let
    EndDate =               if EndDate is null then Date.From(DateTime.FixedLocalNow()) else EndDate,
    DayCount =              Duration.Days(Duration.From(EndDate - StartDate))+1,
    Source =                List.Dates(StartDate,DayCount,#duration(1,0,0,0)),
    TableFromList =         Table.FromList(Source, Splitter.SplitByNothing(),{"Date"}),   
    ChangedType =           Table.TransformColumnTypes(TableFromList,{{"Date", type date}}),
    InsertYear =            Table.AddColumn(ChangedType, "Year",                      each Int64.From(Date.Year([Date])),Int64.Type),
    InsertQuarter =         Table.AddColumn(InsertYear, "QuarterOfYear",              each Int64.From(Date.QuarterOfYear([Date])),Int64.Type),
    InsertMonth =           Table.AddColumn(InsertQuarter, "MonthOfYear",             each Int64.From(Date.Month([Date])),Int64.Type),
    InsertDay =             Table.AddColumn(InsertMonth, "DayOfMonth",                each Int64.From(Date.Day([Date])),Int64.Type),
    InsertDayInt =          Table.AddColumn(InsertDay, "DateInt",                     each Int64.From([Year] * 10000 + [MonthOfYear] * 100 + [DayOfMonth]),Int64.Type),
    InsertMonthName =       Table.AddColumn(InsertDayInt, "MonthName",                each Date.ToText([Date], "MMMM"), type text),
    InsertCalendarMonth =   Table.AddColumn(InsertMonthName, "MonthInCalendar",       each (try(Text.Range([MonthName],0,3)) otherwise [MonthName]) & " " & Number.ToText([Year])),
    InsertCalendarQtr =     Table.AddColumn(InsertCalendarMonth, "QuarterInCalendar", each "Q" & Number.ToText([QuarterOfYear]) & " " & Number.ToText([Year])),
    InsertDayWeek =         Table.AddColumn(InsertCalendarQtr, "DayInWeek",           each Int64.From(Date.DayOfWeek([Date])),Int64.Type),
    InsertDayName =         Table.AddColumn(InsertDayWeek, "DayOfWeekName",           each Date.ToText([Date], "dddd"), type text),
    InsertWeekNumber=       Table.AddColumn(InsertDayName, "Week Number",             each Int64.From(Date.WeekOfYear([Date])),Int64.Type)
    in
    InsertWeekNumber
    in Value.ReplaceType(fn,tp)
    in Source
