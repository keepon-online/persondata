layui.config({
	base : "assets/js/"
}).use(['flow','form','layer'],function(){
    var flow = layui.flow,
        form = layui.form(),
        layer = parent.layer === undefined ? layui.layer : parent.layer,
        $ = layui.jquery;

    //流加载图片
    var imgNums = 10;  //单页显示图片数量
    flow.load({
        elem: '#Images', //流加载容器
        done: function(page, next){ //加载下一页
            $.get("picturelist",function(data){
                var imgList = [];
                var maxPage = imgNums*page < data.length ? imgNums*page : data.length;
                setTimeout(function(){
                    for(var i=imgNums*(page-1); i<maxPage; i++){
                        imgList.push('<li><img style="width:200px;height:200px" src="'+ data[i].name +'"><div class="operate"><div class="check"><input type="checkbox" name="belle" lay-filter="choose" lay-skin="primary" title="'+data[i].imageFileName+'"></div><i class="layui-icon img_del">&#xe640;</i></div></li>')
                    }
                    next(imgList.join(''), page < (data.length/imgNums));
                    form.render();
                }, 500);
            }); 
        }
    });
    //图片上传
    $(".batchUppic").click(function(){
		var index = layui.layer.open({
			title : "上传图片",
			type : 2,
			content : "pictureAdd",
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

    //删除单张图片
    $("body").on("click",".img_del",function(){
        var _this = $(this);
        layer.confirm('确定删除图片"'+_this.siblings().find("input").attr("title")+'"吗？',{icon:3, title:'提示信息'},function(index){
            _this.parents("li").hide(1000);
            setTimeout(function(){_this.parents("li").remove();},950);
            layer.close(index);
        });
    })

    //全选
    form.on('checkbox(selectAll)', function(data){
        var child = $("#Images li input[type='checkbox']");
        child.each(function(index, item){
            item.checked = data.elem.checked;
        });
        form.render('checkbox');
    });

    //通过判断文章是否全部选中来确定全选按钮是否选中
    form.on("checkbox(choose)",function(data){
        var child = $(data.elem).parents('#Images').find('li input[type="checkbox"]');
        var childChecked = $(data.elem).parents('#Images').find('li input[type="checkbox"]:checked');
        if(childChecked.length == child.length){
            $(data.elem).parents('#Images').siblings("blockquote").find('input#selectAll').get(0).checked = true;
        }else{
            $(data.elem).parents('#Images').siblings("blockquote").find('input#selectAll').get(0).checked = false;
        }
        form.render('checkbox');
    })

    //批量删除
    $(".batchDel").click(function(){
        var $checkbox = $('#Images li input[type="checkbox"]');
        var $checked = $('#Images li input[type="checkbox"]:checked');
        if($checkbox.is(":checked")){
            layer.confirm('确定删除选中的图片？',{icon:3, title:'提示信息'},function(index){
                var index = layer.msg('删除中，请稍候',{icon: 16,time:false,shade:0.8});
                setTimeout(function(){
                    //删除数据
                    $checked.each(function(){
                        $(this).parents("li").hide(1000);
                        setTimeout(function(){$(this).parents("li").remove();},950);
                    })
                    $('#Images li input[type="checkbox"]').prop("checked",false);
                    form.render();
                    layer.close(index);
                    layer.msg("删除成功");
                },2000);
            })
        }else{
            layer.msg("请选择需要删除的图片");
        }
    })

})