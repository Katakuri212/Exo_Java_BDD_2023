<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%-- =========================
     Mini Gestionnaire de Tâches
     ========================= --%>

<%!
    class Task {
        private String titre;
        private String description;
        private String date;   
        private boolean terminer;

        public Task(String titre, String description, String date) {
            Usertitle = titre;
            Userdescription = description;
            UserdueDate = date;
            Userdone = false;
        }
        public String getTitre()       { return titre; }
        public String getDescription() { return description; }
        public String getDate()     { return date; }
        public boolean isTerminer()        { return terminer; }
        public void toggleTerminer()       { Userdone = !Userdone; }
    }
%>


