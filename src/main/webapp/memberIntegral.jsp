<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8"/>
    <title>云之道传销查询系统 - 积分历史</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0"/>

    <!-- bootstrap & fontawesome -->
    <link href="components/bootstrap-3.3.7-dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="components/font-awesome/css/font-awesome.css"/>

    <!-- page specific plugin styles -->
    <!-- ace styles -->
    <link rel="stylesheet" href="assets/css/ace.css" class="ace-main-stylesheet" id="main-ace-style"/> <!--重要-->

    <!-- HTML5shiv and Respond.js for IE8 to support HTML5 elements and media queries -->

    <!--[if lte IE 8]-->
    <%--  <script src="js/html5shiv/dist/html5shiv.js"></script>
      <script src="js/respond/dest/respond.min.js"></script>--%>
    <!--[endif]-->
    <!-- basic scripts -->

    <script src="js/jquery-3.2.0.min.js"></script>

    <!--<script src="components/bootstrap/dist/js/bootstrap.js"></script>-->
    <script src="js/bootstrap.min.js"></script>

    <!-- page specific plugin scripts -->
    <!-- static.html end-->
    <script src="js/datatables/jquery.dataTables.min.js"></script>
    <script src="js/datatables/jquery.dataTables.bootstrap.min.js"></script>
    <%--<script src="js/datatables.net-buttons/dataTables.buttons.min.js"></script>--%>

    <script src="components/datatables.net-buttons/js/dataTables.buttons.js"></script>
    <script src="components/datatables.net-buttons/js/buttons.html5.js"></script>
    <script src="components/datatables.net-buttons/js/buttons.print.js"></script>
    <script src="js/datatables/dataTables.select.min.js"></script>
    <script src="js/jquery-ui/jquery-ui.min.js"></script>

    <%--<script src="js/jquery.form.js"></script>--%>
    <script src="js/func.js"></script>
    <script src="js/common.js"></script>

    <link rel="stylesheet" href="css/jqueryui/jquery-ui.min.css"/>
    <link rel="stylesheet" href="components/jquery-ui.custom/jquery-ui.custom.css"/>

    <script type="text/javascript">
        jQuery(function ($) {
            var memberNo = $.getUrlParam("memberNo");
            var pPurseName = $.getUrlParam("purseName") === null ? null : decodeURI($.getUrlParam("purseName"));
            //console.log("pPurseName:" +( decodeURI($.getUrlParam("purseName")) === null));
            $.getJSON("/listMember.jspx?memberNo=" + memberNo, function (result) { //https://www.cnblogs.com/liuling/archive/2013/02/07/sdafsd.html
                if (result.data.length > 0) {
                    //var memberInfo = JSON.parse(result.data[0].memberInfo);
                    $('#realName').text(result.data[0].realName);
                }
            });
            $.getJSON("/getPurseType.jspx?memberNo=" + memberNo, function (result) { //https://www.cnblogs.com/liuling/archive/2013/02/07/sdafsd.html
                //console.log("length:" + result.length);
                if (result.length > 0) {
                    $("#purseType option:gt(0)").remove();
                    let selectedIndex = 0;
                    $.each(result, function (n, value) {
                        //console.log("value:" + value.pursename);
                        $('#purseType').append('<option value="{0}" selected="selected">{1}</option>'.format(value.id, value.pursename));
                        if (value.pursename === pPurseName) selectedIndex = value.id;
                    });
                    //console.log("selectedIndex:" + selectedIndex);
                    $('#purseType').val(selectedIndex);
                    /*if (selectedIndex > 0)
                        myTable.ajax.url(url + '&purseType=' + selectedIndex).load();*/

                    getReasonCode(selectedIndex);
                    pPurseName = null;
                }
            });

            //getReasonCode();

            function getReasonCode(purseType) {
                var url = "/getReasonCode.jspx?memberNo=" + memberNo;
                if (purseType != null)
                    url += "&purseType=" + purseType;
                $.getJSON(url, function (result) { //https://www.cnblogs.com/liuling/archive/2013/02/07/sdafsd.html
                    //console.log("length:" + result.length);
                    if (result.length > 0) {
                        $("#reasonCode option:gt(0)").remove();
                        $.each(result, function (n, value) {
                            //console.log("value:" + value.pursename);
                            if(value)
                            $('#reasonCode').append('<option value="{0}" selected="selected">{1}</option>'.format(value.code, value.reasonname));
                        });
                        $('#reasonCode').val(0);
                    }
                });
            }

            var url = "/memberIntegral.jspx?memberNo=" + memberNo + (pPurseName === null ? "" : "&purseName=" + pPurseName);
            $('#purseType').change(function () {
                var purseType = $(this).children('option:selected').val();
                if (purseType > 0) {
                    myTable.ajax.url(url + '&purseType=' + purseType).load();
                    getReasonCode(purseType);
                } else {
                    myTable.ajax.url(url).load();
                    getReasonCode();
                }
            });
            $('#reasonCode').change(function () {
                var purseType = $('#purseType').children('option:selected').val();
                var reasonCode = $(this).children('option:selected').val();
                if (reasonCode > 0) {
                    myTable.ajax.url(url + '&purseType=' + purseType + '&reasonCode=' + reasonCode).load();
                } else {
                    myTable.ajax.url(url).load();
                }
            });
            var myTable = $('#dynamic-table')
            //.wrap("<div class='dataTables_borderWrap' />")   //if you are applying horizontal scrolling (sScrollX)
                .DataTable({
                    bAutoWidth: false,
                    "columns": [
                        {"data": "id", "sClass": "center"},
                        {"data": "created_at", "sClass": "center"},
                        {"data": "pursename", "sClass": "center"},
                        {"data": "reasonname", "sClass": "center"},
                        {"data": "intoamount", "sClass": "center", sDefaultContent: ''},
                        {"data": "intobalance", "sClass": "center", sDefaultContent: ''}
                    ],

                    'columnDefs': [
                        {"orderable": false, className: 'text-center', "targets": 0},
                        {"orderable": false, className: 'text-center', "targets": 1},
                        {"orderable": false, className: 'text-center', "targets": 2},
                        {"orderable": false, className: 'text-center', "targets": 3},
                        {"orderable": false, className: 'text-center', "targets": 4},
                        {"orderable": false, className: 'text-center', 'targets': 5}

                    ],
                    "aLengthMenu": [[20, 100, 1000,-1], ["20", "100","1000", "全部"]],//二组数组，第一组数量，第二组说明文字;
                    "aaSorting": [],//"aaSorting": [[ 4, "desc" ]],//设置第5个元素为默认排序
                    language: {
                        url: '/js/datatables/datatables.chinese.json'
                    },
                    searching: false,
                    scrollY: '60vh',
                    // "ajax": url,
                    "ajax": {
                        url: url,
                        "data": function (d) {//删除多余请求参数
                            for (let key in d)
                                if (key.indexOf("columns") === 0 || key.indexOf("order") === 0 || key.indexOf("search") === 0)  //以columns开头的参数删除
                                    delete d[key];
                        }
                    },
                    "processing": true,
                    "serverSide": true,
                    select: {style: 'single'}
                });
            myTable.on('order.dt search.dt draw.dt', function () {
                myTable.column(0, {search: 'applied', order: 'applied'}).nodes().each(function (cell, i) {
                    cell.innerHTML = i + 1;
                });
            });

            //$.fn.dataTable.Buttons.defaults.dom.container.className = 'dt-buttons btn-overlap btn-group btn-overlap';
            new $.fn.dataTable.Buttons(myTable, {
                buttons: [
                    {
                        "extend": "copy",
                        "text": "<i class='fa fa-copy bigger-110 pink'></i> <span class='hidden'>Copy to clipboard</span>",
                        "className": "btn btn-white btn-primary btn-bold"
                    },
                    {
                        "extend": "csv",
                        "text": "<i class='fa fa-database bigger-110 orange'></i> <span class='hidden'>Export to CSV</span>",
                        "className": "btn btn-white btn-primary btn-bold"
                    },
                    {
                        "extend": "excel",
                        "text": "<i class='fa fa-file-excel-o bigger-110 green'></i> <span class='hidden'>Export to Excel</span>",
                        "className": "btn btn-white btn-primary btn-bold"
                    },
                    {
                        "extend": "pdf",
                        "text": "<i class='fa fa-file-pdf-o bigger-110 red'></i> <span class='hidden'>Export to PDF</span>",
                        "className": "btn btn-white btn-primary btn-bold"
                    },
                    {
                        "extend": "print",
                        "text": "<i class='fa fa-print bigger-110 grey'></i> <span class='hidden'>Print</span>",
                        "className": "btn btn-white btn-primary btn-bold",
                        autoPrint: false
                    }
                ]
            }); // todo why only copy csv print
            myTable.buttons().container().appendTo($('.tableTools-container'));
            /*$('button:last').click(function () {
                $(window).attr('location', 'member.jspx');
            });*/
        })
    </script>
</head>
<body class="no-skin">
<div class="main-container ace-save-state" id="main-container">
    <script type="text/javascript">
        try {
            ace.settings.loadState('main-container')
        } catch (e) {
        }
    </script>
    <div class="main-content">
        <div class="main-content-inner">

            <div class="breadcrumbs" id="breadcrumbs">
                <ul class="breadcrumb">
                    <label>钱包类型 ：</label>
                    <select id="purseType" class="nav-search-input">
                        <option value="0" selected>全部</option>
                        <option value="1">现金钱包</option>
                        <option value="6">大云豆</option>
                        <option value="7">小云豆</option>
                        <option value="8">销售额</option>
                        <option value="9">创业佣金</option>
                        <option value="10">合伙商现金钱包</option>
                        <option value="11">直接结算到卡的销售额度</option>
                    </select>
                    <span class="space-4"/>
                    <label>进帐说明 ：</label>
                    <select id="reasonCode" class="nav-search-input">
                        <option value="0" selected>全部</option>
                    </select>
                </ul>

            </div>
            <!-- /section:basics/content.breadcrumbs -->
            <div class="page-content">

                <div class="row">
                    <div class="col-xs-12">

                        <div class="row">

                            <div class="col-xs-12">
                                <div class="table-header">
                                    <span id="realName"></span> 积分明细
                                    <div class="pull-right tableTools-container"></div>
                                </div>
                                <!-- div.table-responsive -->

                                <!-- div.dataTables_borderWrap -->
                                <div>
                                    <table id="dynamic-table" class="table table-striped table-bordered table-hover">
                                        <thead>
                                        <tr>
                                            <th></th>
                                            <th>日期</th>
                                            <th>钱包类型</th>
                                            <th>进账说明</th>
                                            <th>进账金额</th>
                                            <th>余额</th>
                                        </tr>
                                        </thead>
                                    </table>
                                </div>
                            </div>
                        </div>

                        <!-- PAGE CONTENT ENDS -->
                    </div><!-- /.col -->
                </div><!-- /.row -->

            </div><!-- /.page-content -->
        </div><!-- /.main-container-inner -->
    </div><!-- /.main-content -->
    <div class="footer">
        <div class="footer-inner">
            <!-- #section:basics/footer -->
            <div class="footer-content">
                <span class="bigger-120"><span class="blue bolder">广东鑫证</span>司法鉴定所 &copy; 2018
                </span>
            </div>
            <!-- /section:basics/footer -->
        </div>
    </div>
</div><!-- /.main-container -->

</body>
</html>