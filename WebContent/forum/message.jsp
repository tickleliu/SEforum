<%@ page contentType='text/html; charset=UTF-8' %>
<%@ page import='java.io.*' %>
<%@ page import='javax.servlet.*' %>
<%@ page import='javax.servlet.http.*' %>
<%@ page import='java.sql.*' %>
<%@ page import='java.sql.Connection' %>
<%@ page import='java.sql.Statement' %>
<%@ page import='java.sql.ResultSet' %>
<%@ page import='forum.*' %>

<% String sessionUsername = (String)session.getAttribute("username"); %>
<% String sessionPassword = (String)session.getAttribute("password"); %>
<% String sessionType = (String)session.getAttribute("type"); %>

<% String forum_id = request.getParameter("forum_id"); %>
<% String reqThread_id = request.getParameter("thread_id"); %>
<% String start = request.getParameter("start"); %>
      				
<% Utilities.addView(forum_id,reqThread_id); %>
<jsp:include page="./include/header.jsp" flush="true">
	<jsp:param name="title" value="Read Message" /> 
</jsp:include>	 
<jsp:include page="./include/body.jsp" flush="true" />
<% if( sessionUsername != null){%>
	<table width="100%" height="20" border="0" cellpadding="1" cellspacing="1">
		<tr> 
			<td height="20" valign="top" class="pathBar">
				<a href="index.jsp" class="pathBarLink"><%= Variable.getForumName() %></a><span class="pathBarSeperator"> > </span>
				<a href="./index.jsp?page=thread&forum_id=<%= forum_id %>" class="pathBarLink"><%= Utilities.getforumTile(forum_id) %></a><span class="pathBarSeperator"> > </span>
				<a href="./index.jsp?page=thread&forum_id=<%= forum_id %>&thread_id=<%=reqThread_id%>&start=<%= start %>" class="pathBarLink"><%= Utilities.getThreadTile(reqThread_id) %></a>
			</td>
			<td height="20" align="right" class="pathBar">
						<a href="./addthread.jsp?forum_id=<%= forum_id %>" class="pathBarLink">发布交易信息</a>&nbsp;&nbsp;&nbsp;&nbsp;						
                        <a href="search.jsp" class="pathBarLink">进入搜索页面</a>					
             </td>			
			<TD align="right" class="pathBar">
				<%= Utilities.getMorePages(Utilities.getReplies(forum_id,reqThread_id),forum_id,reqThread_id,false) %>
			</TD>
		</tr>
	</table>
	<jsp:include page="./include/table_start.jsp" flush="true" />                   

	<%					
	DBConnectie db = new DBConnectie();

	db.connect();
						
	String thread_id = "null";

	ResultSet rs = db.selectQuery(
		"SELECT * FROM forum_message " +
		"WHERE forum_id=\"" + forum_id + "\" AND thread_id =\"" + reqThread_id + "\" ORDER BY id LIMIT "+ start + "," + Variable.getMessagePerPage());
							
		while(rs.next()){
			thread_id = rs.getString("thread_id");
			String message_id = rs.getString("id");
			String message = rs.getString("message");
			String user_id = rs.getString("user_id");
			String user = Utilities.getUser(user_id);
			String date_time = rs.getString("date_time");
	%>						
	<jsp:include page="./include/table_start_title.jsp" flush="true" />
	<% String titleAdmin = "发表于: " + date_time + "&nbsp;&nbsp;&nbsp;<a href=\"./index.jsp?page=editmessage&forum_id=" + forum_id + "&thread_id=" + thread_id + "&message_id=" + message_id + "&start=" + start + "\">修改</a>&nbsp;&nbsp;&nbsp;<a href=\"../servlet/forum.DeleteReply?forum_id=" + forum_id + "&thread_id=" + thread_id + "&message_id=" + message_id + "&start=" + start + "\">删除</a>"; %>
	<% String titleUser = "发表于: " + date_time + "&nbsp;&nbsp;&nbsp;<a href=\"./index.jsp?page=editmessage&forum_id=" + forum_id + "&thread_id=" + thread_id + "&message_id=" + message_id + "&start=" + start + "\">修改</a>"; %>
	<% String titleOther = "发表于: " + date_time; %>
	<% if(sessionType.equals("Admin")){ %>
		<jsp:include page="./include/table_title.jsp" flush="true">
			<jsp:param name="title" value="<%= titleAdmin %>" /> 
			<jsp:param name="colspan" value="2" /> 
			<jsp:param name="align" value="middle" /> 
		</jsp:include>
	<% }else{ %>
		<% if(sessionUsername.equals(user)){ %>
				<jsp:include page="./include/table_title.jsp" flush="true">
					<jsp:param name="title" value="<%= titleUser %>" /> 
					<jsp:param name="colspan" value="2" /> 
					<jsp:param name="align" value="middle" /> 
				</jsp:include>
		<% }else{ %>		
				<jsp:include page="./include/table_title.jsp" flush="true">
					<jsp:param name="title" value="<%= titleOther %>" /> 
					<jsp:param name="colspan" value="2" /> 
					<jsp:param name="align" value="middle" /> 
				</jsp:include>			        
		<% } %>
	<% } %>		
		
	<jsp:include page="./include/table_start_body.jsp" flush="true" />							

	<%    	
								
		ResultSet rs2 = db.selectQuery(
			"SELECT * FROM forum_users WHERE user_name =\"" + user + "\"");
			
		String group = null;
		String avatar = null;
		String member_title = null;
		String signature = null;	
		while(rs2.next()){
			group = rs2.getString("type");
			avatar = rs2.getString("avatar");
			member_title = rs2.getString("member_title");
			signature = rs2.getString("signature");
		}
						
		ResultSet rs3 = db.selectQuery(
			"SELECT count(*) count FROM forum_message WHERE user_id =\"" + user_id + "\"");
		
		while(rs3.next()){
			String messageCount = rs3.getString("count");
									
			if(avatar == null){
				avatar = "<br>";
			}else{
				avatar = "<img src=\"" + avatar + "\" width=\"65\" height=\"65\"><br>";								
			}						
			if(member_title == null){
				member_title = "";
			}else{
				member_title = member_title + "<br>";
			}						
			if(signature == null){
				signature = "";
			}else{
				signature =	"<br><br>--------<br>" + signature;
			}
	%>									
			<jsp:include page="./include/table_body.jsp" flush="true">
				<jsp:param name="width" value="100" /> 
			</jsp:include>								
			<b><%= user.toUpperCase() %></b>
			<br>
			<%= member_title %>
			<%= avatar %><br>
			用户组: <%= group %><br>
			信息数: <%= messageCount %><br>
		<% } %>
		<jsp:include page="./include/table_body.jsp" flush="true">
			<jsp:param name="width" value="400" /> 
		</jsp:include>		
		<%= message %><%= signature %>
			
		<jsp:include page="./include/table_close_body.jsp" flush="true" /> 

	<% } %>
	<% db.close(); %>				
	<jsp:include page="./include/table_start_title.jsp" flush="true" /> 
	<% String back = "<a href=\"./index.jsp?page=thread&forum_id=" + forum_id + "\">返回</a> " + Utilities.getMorePages(Utilities.getReplies(forum_id,thread_id),forum_id,thread_id,false); %>
	<jsp:include page="./include/table_title.jsp" flush="true">
		<jsp:param name="title" value="<%= back %>" /> 
		<jsp:param name="colspan" value="2" /> 
		<jsp:param name="align" value="left" /> 
	</jsp:include>	
	<jsp:include page="./include/table_close.jsp" flush="true" /> 
	<br>
	<jsp:include page="./include/table_start.jsp" flush="true" /> 
	<jsp:include page="./include/table_title.jsp" flush="true">
		<jsp:param name="title" value="增加回复" /> 
		<jsp:param name="colspan" value="3" /> 
		<jsp:param name="align" value="left" /> 
	</jsp:include>					
	<jsp:include page="./include/table_start_body.jsp" flush="true" />
	<jsp:include page="./include/table_body.jsp" flush="true">
		<jsp:param name="width" value="200" /> 
	</jsp:include> 					

	<form action="../servlet/forum.AddReply" method="POST" name="formmessage">
	<input type="hidden" name="forum_id" value="<%= forum_id %>">
	<input type="hidden" name="thread_id" value="<%= thread_id %>">
	<input type="hidden" name="user" value="<%= sessionUsername %>">
	<input type="hidden" name="start" value="<%= start %>">
	回复内容:<br>
	<textarea name="message" cols="45" rows="10" maxlength=3000></textarea><br>
	<input type="submit" value="提交">
	</form>

	<jsp:include page="./include/table_body.jsp" flush="true">
		<jsp:param name="width" value="200" /> 
	</jsp:include>
	<jsp:include page="./include/textStyle.jsp" flush="true" />

	<jsp:include page="./include/table_body.jsp" flush="true">
		<jsp:param name="width" value="200" /> 
	</jsp:include>
	<jsp:include page="./include/emoticons.jsp" flush="true" />
	<jsp:include page="./include/table_close_body.jsp" flush="true" />				 
	<jsp:include page="./include/table_close.jsp" flush="true" />        
        		
              
<% }else { %>
	<br>
	<jsp:include page="./include/table_start.jsp" flush="true" /> 
	<jsp:include page="./include/table_title.jsp" flush="true">
		<jsp:param name="title" value="出错啦 :(" /> 
		<jsp:param name="colspan" value="1" /> 
		<jsp:param name="align" value="left" /> 
	</jsp:include>						
	<jsp:include page="./include/table_start_body.jsp" flush="true" />
	<jsp:include page="./include/table_body.jsp" flush="true">
		<jsp:param name="width" value="200" /> 
	</jsp:include>
	请先登录!
	<br>
	<br>
	<a href="./register.jsp">注册</a>
	<jsp:include page="./include/table_close_body.jsp" flush="true" />				 
	<jsp:include page="./include/table_close.jsp" flush="true" />
<% } %>   
<jsp:include page="./include/footer.jsp" flush="true" />  
         
