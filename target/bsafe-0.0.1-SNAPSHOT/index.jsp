<html>
<head>
<title>B-Safe System</title>
</head>
<body>
	
	<h1>B-Safe System</h1>
	
	<h1> Welcome to an AWS, Jenkins, Ansible, Docker, deployment project by Fernando Andrade! </h1>
	
	<p>Now is <%= new java.util.Date() %></p>
	<p>Your IP is <%= request.getRemoteAddr() %></p>
	
    <h2> Welcome visiting B-Safe!</h2>
	<form method="get" action="/bsafe/calc/">
		<br><h3>Multiplication:</h3> 
		<input name="arg1" id="arg1" type="text" value="<%= request.getAttribute("arg1")!=null?(int)request.getAttribute("arg1"):0 %>" /> X <input name="arg2" id="arg2" type="text" value="<%= request.getAttribute("arg2")!=null?(int)request.getAttribute("arg2"):0 %>" /> <input type="submit" id="btnsubmit" value="Calculate"> = <b><span id="result"><%= request.getAttribute("result")!=null?(int)request.getAttribute("result"):0 %></span></b>
	</form>
</body>
	
