import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import QtWebEngine 1.8

import QtGraphicalEffects 1.0
import QtCharts 2.3
import Qaterial 1.0 as Qaterial
import ModelHelper 0.1

import AtomicDEX.WalletChartsCategories 1.0

import "../Components"
import "../Constants"

// Portfolio
InnerBackground {
    id: willyBG
    property bool isProgress: true
    function drawChart() {
        areaLine.clear()
        areaLine3.clear()
        scatter.clear()

        dateA.min = new Date(API.app.portfolio_pg.charts[0].timestamp*1000)
        dateA.max = new Date(API.app.portfolio_pg.charts[API.app.portfolio_pg.charts.length-1].timestamp*1000)
        chart_2.update()
        for (let ii =0; ii<API.app.portfolio_pg.charts.length; ii++) {
            let el = API.app.portfolio_pg.charts[ii]
            try {
                areaLine3.append(el.timestamp*1000, parseFloat(el.total))
                areaLine.append(el.timestamp*1000, parseFloat(el.total))
                scatter.append(el.timestamp*1000, parseFloat(el.total))
            }catch(e) {}
        }
        chart_2.update()
        willyBG.isProgress = false

    }

    Timer {
        id: pieTimer
        interval: 500
        onTriggered: {
            refresh()
        }
    }
    Timer {
        id: chart2Timer
        interval: 500
        onTriggered: {
            if(API.app.portfolio_pg.charts.length===0){
                restart()
            }else {
                willyBG.isProgress = true
                drawTimer.restart()
            }
        }
    }
    Timer {
        id: drawTimer
        interval: 2000
        onTriggered: willyBG.drawChart()
    }
    Connections {
        target: API.app.portfolio_pg
        function onChart_busy_fetchingChanged() {
            if(!API.app.portfolio_pg.chart_busy_fetching){
                willyBG.isProgress = true
                chart2Timer.restart()
            }
        }
    }

    Component.onCompleted: {
        willyBG.isProgress = true
        chart2Timer.restart()


    }
    property real mX: 0
    property real mY: 0
    ClipRRect {
        anchors.fill: parent
        radius: parent.radius
        Glow {
            id: glow
            anchors.fill: chart_2
            radius: 8
            samples: 168
            color: 'purple'
            source: chart_2
        }
        LinearGradient {
            id: gradient
            start: Qt.point(willyBG.mX,willyBG.mY-100)
            end: Qt.point(willyBG.mX,willyBG.mY+100)
            gradient: Gradient {
                GradientStop {
                    position: 1;
                    color: theme.accentColor
                }
                GradientStop {
                    position: 0.3;
                    color: Qt.rgba(86,128,189,0.09)
                }
                GradientStop {
                    position: 0.2;
                    color: Qt.rgba(86,128,189,0.00)
                }
            }
            anchors.fill: glow
            source: glow
        }

        ChartView {
            id: chart_2
            anchors.fill: parent
            anchors.margins: -20
            anchors.topMargin: 50
            anchors.bottomMargin: 5
            theme: ChartView.ChartThemeLight
            antialiasing: true
            legend.visible: false
            backgroundColor: 'transparent'
            dropShadowEnabled: true
            margins.bottom: 5

            opacity: .8
            AreaSeries {
                axisX: DateTimeAxis {
                    id: dateA
                    gridVisible: false
                    lineVisible: false
                    format: "<br>MMM d"
                }
                axisY: ValueAxis {
                    lineVisible: false
                    max:  parseFloat(API.app.portfolio_pg.max_total_chart)
                    min:  parseFloat(API.app.portfolio_pg.min_total_chart)

                    gridLineColor: Qt.rgba(77,198,255,0.12)
                }
                color: Qt.rgba(77,198,255,0.02)
                borderColor: 'transparent'


                upperSeries: LineSeries {
                    id: areaLine
                    axisY: ValueAxis {
                        visible: false
                        max:  parseFloat(API.app.portfolio_pg.max_total_chart)
                        min:  parseFloat(API.app.portfolio_pg.min_total_chart)
                    }
                    axisX: DateTimeAxis {
                        id: dateA2
                        min: dateA.min
                        max: dateA.max
                        gridVisible: false
                        lineVisible: false
                        format: "MMM d"
                    }

                }

            }
            LineSeries {
                id: areaLine3
                color: theme.accentColor
                visible: !isSpline
                axisY: ValueAxis {
                    visible: false
                    max:  parseFloat(API.app.portfolio_pg.max_total_chart)
                    min:  parseFloat(API.app.portfolio_pg.min_total_chart)
                }
                axisX: DateTimeAxis {
                    visible: false
                    min: dateA.min
                    max: dateA.max
                    gridVisible: false
                    lineVisible: false
                    format: "MMM d"
                }
            }
            ScatterSeries {
                id: scatter
                visible: true
                color: theme.accentColor
                borderColor: theme.accentColor
                markerSize: 7
                borderWidth: 3

                onHovered: {
                    let p = chart_2.mapToPosition(point, scatter)
                    if(p.x<170) {
                         boxi.x = p.x
                    }else {
                        boxi.x = p.x-170
                    }


                    boxi.y = p.y+10
                    if(state){
                        boxi.visible = true
                    }else {
                        boxi.visible = false
                    }
                    boxi.value = point.y
                    boxi.timestamp = point.x

                }


                axisY: ValueAxis {
                    visible: false
                    max:  parseFloat(API.app.portfolio_pg.max_total_chart)
                    min:  parseFloat(API.app.portfolio_pg.min_total_chart)
                }
                axisX: DateTimeAxis {
                    visible: false
                    min: dateA.min
                    max: dateA.max
                    gridVisible: false
                    lineVisible: false
                    format: "MMM d"
                }


            }
        }

        Rectangle {
            anchors.fill: parent
            opacity: .6
            color: theme.dexBoxBackgroundColor
            visible: willyBG.isProgress
            radius: parent.radius
            DexBusyIndicator {
                anchors.centerIn: parent
                running: visible
                visible: willyBG.isProgress
            }
        }

        Row {
            y: 15
            x: -20
            spacing: 20
            scale: .8
            FloatingBackground {
                width: rd.width+10
                height: 50

                Row {
                    id: rd
                    anchors.verticalCenter: parent.verticalCenter
                    x: 5
                    layoutDirection: Qt.RightToLeft

                    Qaterial.OutlineButton {
                        text: "YTD"
                        outlinedColor: API.app.portfolio_pg.chart_category.valueOf() === 3? theme.accentColor : theme.backgroundColor
                        onClicked: {
                            API.app.portfolio_pg.chart_category = WalletChartsCategories.Ytd
                        }
                    }
                    Qaterial.OutlineButton {
                        text: "1M"
                        outlinedColor: API.app.portfolio_pg.chart_category.valueOf() === 2? theme.accentColor : theme.backgroundColor
                        onClicked: {
                            API.app.portfolio_pg.chart_category = WalletChartsCategories.OneMonth
                        }
                    }
                    Qaterial.OutlineButton {
                        text: "7D"
                        outlinedColor: API.app.portfolio_pg.chart_category.valueOf() === 1? theme.accentColor : theme.backgroundColor
                        onClicked: API.app.portfolio_pg.chart_category = WalletChartsCategories.OneWeek
                    }
                    Qaterial.OutlineButton {
                        text: "24H"
                        enabled: false
                        outlinedColor: API.app.portfolio_pg.chart_category.valueOf() === 0? theme.accentColor : theme.backgroundColor
                        onClicked: API.app.portfolio_pg.chart_category = 0
                    }
                }
            }
        }

        FloatingBackground {
            id: boxi
            property real value: 0
            property var timestamp
            visible: false
            width: 130
            height: 60
            x: 99999
            y: 99999

            Behavior on x {
                NumberAnimation {
                    duration: 200
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 200
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                x: 10
                spacing: 5
                DexLabel {
                    text: "%1 %2".arg( API.app.settings_pg.current_fiat_sign).arg(boxi.value)
                    color: theme.accentColor
                    font: theme.textType.subtitle2
                }
                DexLabel {
                    text: Qt.formatDate(new Date(boxi.timestamp), "dd MMM yyyy");
                    font: theme.textType.body2
                }
            }
        }
    }
}
