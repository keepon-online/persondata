package online.shixun.project.web;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import online.shixun.project.module.picture.service.PictureService;

@Controller
public class UploadFile {
    @Autowired
    private PictureService pictureService;

    @RequestMapping(value = "/uploadfile")
    @ResponseBody
    public Map<String, Object> uploadFile(@RequestParam(required = false) MultipartFile file,
	    HttpServletRequest request) {
	Map<String, Object> map = new HashMap<String, Object>();
	// 获取图片的原名字
	String oldName = file.getOriginalFilename();
	// 截取图片的类型
	String fileType = oldName.substring(oldName.lastIndexOf("."));
	// 获取当前时间作为新的图片名字 并加上后缀
	String timeName = System.currentTimeMillis() + "";
	String newName = timeName + fileType;
	// 获取项目的路径 在项目路径下新建文件夹
	String path = request.getSession().getServletContext().getRealPath("/upload");
	// 新建 upload 文件夹 不存在就新建
	File parentPath = new File(path);
	if (!parentPath.exists()) {
	    parentPath.mkdirs();
	}
	System.out.println(parentPath);
	System.out.println("id  " + request.getParameter("id"));
	// 新建upload文件夹的 （以当前时间命名的） 子文件夹
	String path2 = path + "/" + timeName;
	File childPath = new File(path2);
	if (!childPath.exists()) {
	    childPath.mkdirs();
	}
	try {
	    // file.transferTo(new File(childPath, newName));
	    if (!newName.isEmpty()) {
		// 拼接图片的相对路径作为URL
		Map<String, Object> map2 = new HashMap<String, Object>();
		String src = "upload/" + timeName + "/" + newName;
		map.put("code", 0);
		map.put("msg", "上传成功！");
		map.put("data", map2);
		map2.put("src", src);
		map2.put("title", newName);
		// PictureDTO pictureDTO = new PictureDTO();
		// pictureDTO.setImageFileName(newName);
		// pictureDTO.setName(src);
		// pictureService.addpicture(pictureDTO);
	    } else {
		map.put("code", -1);
		map.put("msg", "上传失败！");
	    }
	} catch (IllegalStateException e) {
	    e.printStackTrace();
	}
	return map;
    }
}
