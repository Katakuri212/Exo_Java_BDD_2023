<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%-- =========================
     Mini Gestionnaire de Tâches - 1 seul JSP
     ========================= --%>

<%!
    // ---- Modèle : classe Task (POJO simple)
    class Task {
        private String title;
        private String description;
        private String dueDate;   // stockée en texte pour rester simple (AAAA-MM-JJ)
        private boolean done;

        public Task(String title, String description, String dueDate) {
            Usertitle = title;
            Userdescription = description;
            UserdueDate = dueDate;
            Userdone = false;
        }
        public String getTitle()       { return title; }
        public String getDescription() { return description; }
        public String getDueDate()     { return dueDate; }
        public boolean isDone()        { return done; }
        public void toggleDone()       { this.done = !this.done; }
    }
%>


