package com.bsafe;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import javax.servlet.http.HttpServletRequest;
import com.bsafe.CalcApp;

@Controller
public class HomeController {
	
	@RequestMapping("/calc")
	public String calc(int arg1, int arg2, HttpServletRequest request) {
		request.setAttribute("arg1", arg1);
		request.setAttribute("arg2", arg2);
		request.setAttribute("result", CalcApp.calc(arg1, arg2));
		return "/index.jsp";
	}
}
