require(ggplot2);
require(scales);
require(plyr);

csv<-
  c(
    seasonallyAdjusted="seasonallyAdjustedNonfarmPayrolls.csv"
    ,unadjusted="unadjustedNonfarmPayrolls.csv");

chart.titles<-
  c(
    seasonallyAdjusted="Seasonally Adjusted Nonfarm Payrolls"
    , unadjusted="Unadjusted Nonfarm Payrolls"
    , Both="Nonfarm Payrolls");

measures<-
  c("Value"="Jobs (in 000's)", "diff"="Jobs Created (in 000's)");

time.units<-
  c("Year"="Year", "Year_Mo"="Months");

plotchart<-
  function(input){
    if(input$close){stopApp()}
    
    df.1<-
      read.csv(file=csv[1], stringsAsFactor=FALSE);
    
    df.1$data<-
      "seasonallyAdjusted";
    
    df.1$prelim[(nrow(df.1) - 1):nrow(df.1)]<-
      "P"

    df.2<-
      read.csv(file=csv[2], stringsAsFactor=FALSE);
    
    df.2$data<-
      "unadjusted";
    
    df.2$prelim[(nrow(df.2) - 1):nrow(df.2)]<-
      "P"
    
    df<-
      rbind(df.1, df.2);
    
    if(input$data!="Both"){
      df<-
        df[df$data == input$data,];
    }
    
    df$Year_Mo<-
      paste(df$Year, df$Period, sep="\n");
  
    
    df$dff[1]<-
      0;
    
    df$diff[ 2:nrow(df) ]<-
      df$Value[2:nrow(df)] - df$Value[1:nrow(df)-1 ];
    
    
    #df$prelim[1:nrow(df)-2]<-
    #  "A"
    
    df<-
      df[df$Year>=input$year[1] & df$Year<=input$year[2] ,  ];
    
    if(input$time=="Year"){
      
      df<-
        ddply(df
              , c("Year", "data")
              , function(x){
                  response<-
                    sum(x[, c(input$measure)], na.rm=TRUE);
                  
                  names(response)<-
                    input$measure;
                  
                  return(response);
                  });
    }
    
    chart.title<-
      chart.titles[input$data];
    
    
    response<-
      (ggplot(df)
       + ggtitle( chart.title ));
    
    if(input$fill=="Neither"){ 
      response<-
        (response + geom_bar(stat="identity", aes_string(x=input$time, y=input$measure)));
    } else {
      response<-
        (response + geom_bar(stat="identity", aes_string(x=input$time, y=input$measure, fill=input$fill)));
    }
    
    if(input$data=="Both" & input$time=="Year_Mo"){
      response<-
        (response + facet_wrap( ~ data, nrow=2));
    }
    
    if(input$data=="Both" & input$time=="Year"){
      print(df);
      response<-
        (response + facet_wrap( ~ data, nrow=2));
    }
    
   response<-
      (response
      + scale_y_continuous(measures[input$measure], labels=comma)
      + xlab(time.units[input$time])
      + theme_bw()
      );
   
   return(response);
  }


fn<-
  function(input, output){
    output$chart<-
      renderPlot(plotchart(input=input));
    
  }

shinyServer( fn );