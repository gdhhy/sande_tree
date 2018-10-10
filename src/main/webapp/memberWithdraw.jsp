<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8"/>
    <title>云之道传销查询系统 - 提现记录</title>
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
    <script src="js/accounting.min.js"></script>

    <link rel="stylesheet" href="css/jqueryui/jquery-ui.min.css"/>
    <link rel="stylesheet" href="components/jquery-ui.custom/jquery-ui.custom.css"/>

    <script type="text/javascript">
        jQuery(function ($) {
            var memberNo = $.getUrlParam("memberNo");
            var bankcard = $.getUrlParam("bankcard");

            var url = buildSearchParam(memberNo, bankcard);

            function showMemberInfo(memberNo) {
                $.getJSON("/listMember.jspx?memberNo=" + memberNo, function (result) { //https://www.cnblogs.com/liuling/archive/2013/02/07/sdafsd.html
                    if (result.data.length > 0) {
                        $('#realName').text(result.data[0].realName);//",电话号码：" + result.data[0].phone);
                    }
                });
            }

            if (memberNo !== null) showMemberInfo(memberNo);

            var myTable = $('#dynamic-table')
            //.wrap("<div class='dataTables_borderWrap' />")   //if you are applying horizontal scrolling (sScrollX)
                .DataTable({
                    bAutoWidth: false,
                    "columns": [
                        {"data": "id", "sClass": "center"},
                        {"data": "created_at", "sClass": "center"},
                        {"data": "uid", "sClass": "center"},
                        {"data": "amount", "sClass": "center"},
                        {"data": "realname", "sClass": "center"},
                        {"data": "bank", "sClass": "center"},
                        {"data": "bankcard", "sClass": "center"},
                        {"data": "mobile", "sClass": "center"},
                        {"data": "withdrawClass", "sClass": "center"},
                        {"data": "status", "sClass": "center"},
                        {"data": "remarks", "sClass": "center"},
                        {"data": "c_ip", "sClass": "center"},
                        {"data": "balance_left", "sClass": "center"}
                    ],

                    'columnDefs': [
                        {"orderable": false, className: 'text-center', "targets": 0},
                        {"orderable": true, className: 'text-center', "targets": 1},
                        {
                            "orderable": true, className: 'text-center', "targets": 2,
                            render: function (data, type, row, meta) {
                                return '<a href="#" class="research" name="memberNo" >{0}</a>'.format(data);
                            }
                        },
                        {"orderable": true, className: 'text-center', "targets": 3},
                        {"orderable": true, className: 'text-center', "targets": 4},
                        {"orderable": true, className: 'text-center', 'targets': 5},
                        {
                            "orderable": true, className: 'text-center', 'targets': 6,
                            render: function (data, type, row, meta) {
                                return '<a href="#" class="research" name="bankcard"  >{0}</a>'.format(data);
                            }
                        },
                        {"orderable": true, className: 'text-center', 'targets': 7},
                        {"orderable": true, className: 'text-center', 'targets': 8},
                        {"orderable": true, className: 'text-center', 'targets': 9},
                        {"orderable": true, className: 'text-center', 'targets': 10, defaultContent: ''},
                        {"orderable": true, className: 'text-center', 'targets': 11, defaultContent: ''},
                        {"orderable": true, className: 'text-center', 'targets': 12}

                    ],
                    // "aLengthMenu": [[20, 100, -1], ["20", "100", "全部"]],//二组数组，第一组数量，第二组说明文字;
                    "aaSorting": [],//"aaSorting": [[ 4, "desc" ]],//设置第5个元素为默认排序
                    language: {
                        url: '/js/datatables/datatables.chinese.json'
                    },
                    searching: false,
                    "ajax": url,
                    scrollY: '55vh',
                    "processing": true,
                    "paging": false, // 禁止分页
                    //"serverSide": true,
                    select: {style: 'single'},
                    "footerCallback": function (tfoot, data, start, end, display) {
                        let total = 0.0;
                        $.each(data, function (index, value) {
                            if (value["status"] === '成功')
                                total += value["amount"];
                        });
                        // Update footer
                        $(tfoot).find('th').eq(0).html('成功提现合计： ' + accounting.formatMoney(total, '￥'));
                    }
                });
            myTable.on('order.dt search.dt', function () {
                myTable.column(0, {search: 'applied', order: 'applied'}).nodes().each(function (cell, i) {
                    cell.innerHTML = i + 1;
                });
            });

            /* myTable.on('xhr', function (e, settings, json, xhr) {
                 $('#footTotal').text('成功提现合计：' + accounting.formatMoney(json.total, '￥'));
             });*/
            myTable.on('draw', function () {
                $('#dynamic-table tr').find('.research').click(function () {
                    var url = "/memberWithdraw.jspx?{0}={1}".format($(this).attr("name"), $(this).text());
                    $('.form-search')[0].reset();
                    $('input[name="' + $(this).attr("name") + '"]').val($(this).text());
                    myTable.ajax.url(encodeURI(url)).load();

                    if ($(this).attr("name") === 'memberNo')
                        showMemberInfo($(this).text());
                    else
                        $('#realName').text('银行卡：' + $(this).text());
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

            /* $('button:last').click(function () {
                 $(window).attr('location', 'member.jspx');
             });*/
            $('.btn-success').click(function () {
                search();
            });
            $('.form-search :text').keydown(function (event) {
                if (event.keyCode === 13)
                    search();
            });

            $('.form-search :text:eq(0)').each(function () {
                $(this).width(80);
            });
            $('.form-search :text:eq(1)').each(function () {
                $(this).width(160);
            });

            function search() {
                let url = "/memberWithdraw.jspx";
                let searchParam = "";
                $('.form-search :text').each(function () {
                    if ($(this).val())
                        searchParam += "&" + $(this).attr("name") + "=" + $(this).val();
                });
                if (searchParam !== "") {
                    url = "/memberWithdraw.jspx?" + searchParam.substr(1);
                    $('#realName').text('');
                }
                myTable.ajax.url(url).load();
            }

            function buildSearchParam(memberNo, bankcard) {
                let searchParam = "";
                if (memberNo !== null) {
                    searchParam += "&memberNo=" + memberNo;
                    $('input[name="memberNo"]').val(memberNo);
                }
                if (bankcard !== null) {
                    searchParam += "&bankcard=" + bankcard;
                    $('input[name="bankcard"]').val(bankcard);
                }
                return "/memberWithdraw.jspx?" + searchParam.substr(1);
            }
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
                    <form class="form-search form-inline">
                        <label>用户ID ：</label>
                        <input type="text" name="memberNo" placeholder="用户ID……" class="nav-search-input"
                               autocomplete="off"/><%--
                        姓名：
                        <input type="text" name="realName" placeholder="姓名……" class="nav-search-input"
                               autocomplete="off"/>--%>
                        银行卡号：
                        <input type="text" name="bankcard" placeholder="银行卡号……" class="nav-search-input"
                               autocomplete="off"/>
                    </form>
                </ul>
                <!-- #section:basics/content.searchbox -->
                <div class="nav-search" id="nav-search">
                    <button type="button" class="btn btn-sm btn-success">
                        搜索
                        <i class="ace-icon fa fa-arrow-right icon-on-right bigger-110"></i>
                    </button>
                </div><!-- /.nav-search -->

                <!-- /section:basics/content.searchbox -->
            </div>
            <div class="page-content">

                <div class="row">
                    <div class="col-xs-12">

                        <div class="row">

                            <div class="col-xs-12">
                                <div class="table-header">
                                    <span id="realName"></span> 提现记录
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
                                            <th>用户ID</th>
                                            <th>金额</th>
                                            <th>姓名</th>
                                            <th>银行</th>
                                            <th>卡号</th>
                                            <th>电话</th>
                                            <th>提现类型</th>
                                            <th>状态</th>
                                            <th>备注</th>
                                            <th>操作地址</th>
                                            <th>余额</th>
                                        </tr>
                                        </thead>
                                        <tfoot>
                                        <tr>
                                            <th colspan="12" style="text-align:right">
                                                <div id="footTotal">&nbsp;</div>
                                            </th>
                                        </tr>
                                        </tfoot>
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