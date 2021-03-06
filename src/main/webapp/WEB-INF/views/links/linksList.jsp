<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/commons/taglibs.jsp"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>文章列表--layui后台管理模板</title>
	<meta name="renderer" content="webkit">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
	<meta name="apple-mobile-web-app-status-bar-style" content="black">
	<meta name="apple-mobile-web-app-capable" content="yes">
	<meta name="format-detection" content="telephone=no">
	<link rel="stylesheet" href="${ctx}/assets/layui/css/layui.css" media="all" />
	<link rel="stylesheet" href="//at.alicdn.com/t/font_tnyc012u2rlwstt9.css" media="all" />
	<link rel="stylesheet" href="${ctx}/assets/css/news.css" media="all" />
</head>
<body class="childrenBody">
	<blockquote class="layui-elem-quote news_search">
		<div class="layui-inline">
		    <div class="layui-input-inline">
		    	<input type="text" value="" placeholder="请输入关键字" class="layui-input search_input">
		    </div>
		    <a class="layui-btn search_btn">查询</a>
		</div>
		<div class="layui-inline">
			<a class="layui-btn linksAdd_btn" style="background-color:#5FB878">添加链接</a>
		</div>
		<div class="layui-inline">
			<a class="layui-btn layui-btn-danger batchDel">批量删除</a>
		</div>
	</blockquote>
	<div class="layui-form links_list">
	  	<table class="layui-table">
		    <colgroup>
				<col width="50">
				<col width="30%">
				<col>
				<col>
				<col width="10%">
				<col width="14%">
		    </colgroup>
		    <thead>
				<tr>
					<th><input type="checkbox" name="" lay-skin="primary" lay-filter="allChoose" id="allChoose"></th>
					<th style="text-align:left;">网站名称</th>
					<th>网站地址</th>
					<th>网站描述</th>
					<th>添加时间</th>
					<th>操作</th>
				</tr> 
		    </thead>
		    <tbody class="links_content"></tbody>
		</table>
	</div>
	<div id="page"></div>
	<script type="text/javascript" src="${ctx}/assets/layui/layui.js"></script>
	<script type="text/javascript">
	layui.config({
		base : "assets/js/"
	}).use(['form','layer','jquery','laypage'],function(){
		var form = layui.form(),
			layer = parent.layer === undefined ? layui.layer : parent.layer,
			laypage = layui.laypage,
			$ = layui.jquery;
		var g_rootPath = "${ctx}";
		//加载页面数据
		var linksData = '';
		$.ajax({
			url : g_rootPath+"/link/getlinks",
			type : "get",
			dataType : "json",
			success : function(data){
				linksData = data;
				//执行加载数据的方法
				linksList();
			}
		})

		//查询
		$(".search_btn").click(function(){
			var newArray = [];
			if($(".search_input").val() != ''){
				var index = layer.msg('查询中，请稍候',{icon: 16,time:false,shade:0.8});
	            setTimeout(function(){
	            	$.ajax({
						url : g_rootPath+"/link/getlinks",
						type : "get",
						dataType : "json",
						success : function(data){
							for(var i=0;i<linksData.length;i++){
								var linksStr = linksData[i];
								var selectStr = $(".search_input").val();
			            		function changeStr(data){
			            			var dataStr = '';
			            			var showNum = data.split(eval("/"+selectStr+"/ig")).length - 1;
			            			if(showNum > 1){
										for (var j=0;j<showNum;j++) {
			            					dataStr += data.split(eval("/"+selectStr+"/ig"))[j] + "<i style='color:#03c339;font-weight:bold;'>" + selectStr + "</i>";
			            				}
			            				dataStr += data.split(eval("/"+selectStr+"/ig"))[showNum];
			            				return dataStr;
			            			}else{
			            				dataStr = data.split(eval("/"+selectStr+"/ig"))[0] + "<i style='color:#03c339;font-weight:bold;'>" + selectStr + "</i>" + data.split(eval("/"+selectStr+"/ig"))[1];
			            				return dataStr;
			            			}
			            		}
			            		//链接名称
			            		if(linksStr.linkName.indexOf(selectStr) > -1){
				            		linksStr["linkName"] = changeStr(linksStr.linkName);
			            		}
			            		//链接地址
			            		if(linksStr.linksUrl.indexOf(selectStr) > -1){
				            		linksStr["linksUrl"] = changeStr(linksStr.linksUrl);
			            		}
			            		//链接描述
			            		if(linksStr.linksDesc.indexOf(selectStr) > -1){
				            		linksStr["linksDesc"] = changeStr(linksStr.linksDesc);
			            		}
			            		if(linksStr.linkName.indexOf(selectStr)>-1 || linksStr.linksUrl.indexOf(selectStr)>-1 || linksStr.linksDesc.indexOf(selectStr)>-1){
			            			newArray.push(linksStr);
			            		}
			            	}
			            	linksData = newArray;
			            	linksList(linksData);
						}
					})
	                layer.close(index);
	            },2000);
			}else{
				layer.msg("请输入需要查询的内容");
			}
		})

		//添加友情链接
		$(".linksAdd_btn").click(function(){
			var index = layui.layer.open({
				title : "添加友情链接",
				type : 2,
				content : g_rootPath+"/link/add",
				success : function(layer, index){
					setTimeout(function(){
						layui.layer.tips('点击此处返回友链列表', '.layui-layer-setwin .layui-layer-close', {
							tips: 3
						});
					},500)
				}
			})
			//改变窗口大小时，重置弹窗的高度，防止超出可视区域（如F12调出debug的操作）
			$(window).resize(function(){
				layui.layer.full(index);
			})
			layui.layer.full(index);
		})

		//批量删除
		$(".batchDel").click(function(){
			var $checkbox = $('.links_list tbody input[type="checkbox"][name="checked"]');
			var $checked = $('.links_list tbody input[type="checkbox"][name="checked"]:checked');
			if($checkbox.is(":checked")){
				layer.confirm('确定删除选中的信息？',{icon:3, title:'提示信息'},function(index){
					var index = layer.msg('删除中，请稍候',{icon: 16,time:false,shade:0.8});
		            setTimeout(function(){
		            	//删除数据
		            	var ids="";
		            	for(var j=0;j<$checked.length;j++){
		            		ids += $checked.eq(j).parents("tr").find(".links_del").attr("data-id")+",";
		            	}
		            	// 截取多余字符
		            	ids = ids.substr(0, ids.length - 1);
		            	//发送到服务器
		            	$.post(g_rootPath+"/link/deletes?ids="+ids);
		            	$('.links_list thead input[type="checkbox"]').prop("checked",false);
		            	form.render();
		            	window.location.reload();
		                layer.close(index);
						layer.msg("删除成功");
		            },2000);
		        })
			}else{
				layer.msg("请选择需要删除的链接");
			}
		})

		//全选
		form.on('checkbox(allChoose)', function(data){
			var child = $(data.elem).parents('table').find('tbody input[type="checkbox"]:not([name="show"])');
			child.each(function(index, item){
				item.checked = data.elem.checked;
			});
			form.render('checkbox');
		});

		//通过判断文章是否全部选中来确定全选按钮是否选中
		form.on("checkbox(choose)",function(data){
			var child = $(data.elem).parents('table').find('tbody input[type="checkbox"]:not([name="show"])');
			var childChecked = $(data.elem).parents('table').find('tbody input[type="checkbox"]:not([name="show"]):checked')
			data.elem.checked;
			if(childChecked.length == child.length){
				$(data.elem).parents('table').find('thead input#allChoose').get(0).checked = true;
			}else{
				$(data.elem).parents('table').find('thead input#allChoose').get(0).checked = false;
			}
			form.render('checkbox');
		})
	 
		//操作//编辑
		$("body").on("click",".links_edit",function(){  
			var $this = $(this);
			var id=$this.attr("data-id");
			var index = layui.layer.open({
				title : "友情链接编辑",
				type : 2,
				content : g_rootPath+"/link/edit?id="+id,
				success : function(layero, index){
					setTimeout(function(){
						layui.layer.tips('点击此处返回友链列表', '.layui-layer-setwin .layui-layer-close', {
							tips: 3
						});
					},500)
				}
			})
			//改变窗口大小时，重置弹窗的高度，防止超出可视区域（如F12调出debug的操作）
			$(window).resize(function(){
				layui.layer.full(index);
			})
			layui.layer.full(index);
		})
 		//删除
		$("body").on("click",".links_del",function(){ 
			var _this = $(this);
			var id = _this.attr("data-id");
			layer.confirm('确定删除此信息？',{icon:3, title:'提示信息'},function(index){
				$.ajax({
					url:g_rootPath+"/link/delete",
					type : "post",
					dataType : "json",
					data:{id:id},
					success : function(data){
					
					}
				})
				//刷新页面
				window.location.reload();
				layer.close(index);
			});
		})

		function linksList(that){
			//渲染数据
			function renderDate(data,curr){
				var dataHtml = '';
				if(!that){
					currData = linksData.concat().splice(curr*nums-nums, nums);
				}else{
					currData = that.concat().splice(curr*nums-nums, nums);
				}
				if(currData.length != 0){
					for(var i=0;i<currData.length;i++){
						dataHtml += '<tr>'
				    	+'<td><input type="checkbox" name="checked" lay-skin="primary" lay-filter="choose"></td>'
				    	+'<td align="left">'+currData[i].linkName+'</td>'
				    	+'<td><a style="color:#1E9FFF;" target="_blank" href="'+currData[i].linksUrl+'">'+currData[i].linksUrl+'</a></td>'
				    	+'<td>'+currData[i].linksDesc+'</td>'
				    	+'<td>'+currData[i].createTime+'</td>'
				    	+'<td>'
						+  '<a class="layui-btn layui-btn-mini links_edit" data-id="'+currData[i].id+'"><i class="iconfont icon-edit" ></i> 编辑</a>'
						+  '<a class="layui-btn layui-btn-danger layui-btn-mini links_del" data-id="'+currData[i].id+'"><i class="layui-icon">&#xe640;</i>删除</a>'
				        +'</td>'
				    	+'</tr>';
					}
				}else{
					dataHtml = '<tr><td colspan="6">暂无数据</td></tr>';
				}
			    return dataHtml;
			}

			//分页
			var nums = 10; //每页出现的数据量
			if(that){
				linksData = that;
			}
			laypage({
				cont : "page",
				pages : Math.ceil(linksData.length/nums),
				jump : function(obj){
					$(".links_content").html(renderDate(linksData,obj.curr));
					$('.links_list thead input[type="checkbox"]').prop("checked",false);
			    	form.render();
				}
			})
		}
	})
	</script>
</body>
</html>