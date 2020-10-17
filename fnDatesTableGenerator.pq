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
    DayCount =              Duration.Days(Duration.From(EndDate - StartDate))+1,
    Source =                List.Dates(StartDate,DayCount,#duration(1,0,0,0)),
    TableFromList =         Table.FromList(Source, Splitter.SplitByNothing(),{"Date"}),   
    ChangedType =           Table.TransformColumnTypes(TableFromList,{{"Date", type date}}),
    InsertYear =            Table.AddColumn(ChangedType,          "Year",                      each Int64.From(Date.Year([Date])),Int64.Type),
    InsertQuarter =         Table.AddColumn(InsertYear,           "Quarter",                   each Int64.From(Date.QuarterOfYear([Date])),Int64.Type),
    InsertMonth =           Table.AddColumn(InsertQuarter,        "Month",                     each Int64.From(Date.Month([Date])),Int64.Type),
    InsertDay =             Table.AddColumn(InsertMonth,          "Day In Month",              each Int64.From(Date.Day([Date])),Int64.Type),
    InsertDayInt =          Table.AddColumn(InsertDay,            "DateInt",                   each Int64.From([Year] * 10000 + [Month] * 100 + [Day In Month]),Int64.Type),
    InsertDayWeek =         Table.AddColumn(InsertDayInt,         "Day In Week",               each Int64.From(Date.DayOfWeek([Date])),Int64.Type),
    InsertWeekNumber=       Table.AddColumn(InsertDayWeek,        "Week Number",               each Int64.From(Date.WeekOfYear([Date])),Int64.Type),
    InsertDayName =         Table.AddColumn(InsertWeekNumber,     "Day Name",                  each Date.ToText([Date], "dddd"), type text),
    InsertMonthName =       Table.AddColumn(InsertDayName,        "Month Name",                each Date.ToText([Date], "MMMM"), type text)
    in
    InsertMonthName
    in Value.ReplaceType(fn,tp)
    in Source
