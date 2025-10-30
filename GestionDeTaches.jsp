<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
%>

<%-- ===== Modèle dans CE fichier ===== --%>
<%!
    // Classe simple pour une tâche (POJO)
    class Task {
        private String title, description, dueDate;
        private boolean done;

        public Task(String title, String description, String dueDate) {
            this.title = title;
            this.description = description;
            this.dueDate = dueDate;
            this.done = false;
        }
        public String getTitle() { return title; }
        public String getDescription() { return description; }
        public String getDueDate() { return dueDate; }
        public boolean isDone() { return done; }
        public void toggleDone() { done = !done; }
    }
%>

<%-- ===== Logique serveur dans CE fichier ===== --%>
<%
    java.util.ArrayList<Task> tasks =
        (java.util.ArrayList<Task>) session.getAttribute("tasks");
    if (tasks == null) {
        tasks = new java.util.ArrayList<Task>();
        session.setAttribute("tasks", tasks);
    }

    String action = request.getParameter("action");
    if (action != null) {
        if ("add".equals(action)) {
            String title = request.getParameter("title");
            String desc  = request.getParameter("description");
            String due   = request.getParameter("dueDate");
            if (title != null && !title.trim().isEmpty()) {
                tasks.add(new Task(title.trim(),
                                   desc == null ? "" : desc.trim(),
                                   due  == null ? "" : due.trim()));
            }
        } else if ("toggle".equals(action)) {
            String idxStr = request.getParameter("index");
            if (idxStr != null && idxStr.matches("\\d+")) {
                int idx = Integer.parseInt(idxStr);
                if (idx >= 0 && idx < tasks.size()) {
                    tasks.get(idx).toggleDone();
                }
            }
        } else if ("delete".equals(action)) {
            String idxStr = request.getParameter("index");
            if (idxStr != null && idxStr.matches("\\d+")) {
                int idx = Integer.parseInt(idxStr);
                if (idx >= 0 && idx < tasks.size()) {
                    tasks.remove(idx);
                }
            }
        } else if ("clear".equals(action)) {
            tasks.clear();
        }
    }
%>

<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8"/>
<title>Gestion de tâches (1 seul JSP)</title>
<style>
    body { font-family: Arial, sans-serif; margin: 24px; }
    table { border-collapse: collapse; width: 100%; max-width: 820px; margin-top: 12px; }
    th, td { border: 1px solid #ccc; padding: 8px; vertical-align: top; }
    .done { text-decoration: line-through; color: #777; }
    .actions form { display: inline; margin: 0 4px; }
    input[type=text], input[type=date], textarea { width: 100%; max-width: 520px; }
</style>
</head>
<body bgcolor="white">
<h1>Gestion de tâches</h1>

<h2>Ajouter une tâche</h2>
<form action="GestionDeTaches.jsp" method="post">
    <input type="hidden" name="action" value="add"/>
    <p><label>Titre (obligatoire)</label><br/>
       <input type="text" name="title" required placeholder="Ex. Réviser DS Java"></p>
    <p><label>Description</label><br/>
       <textarea name="description" rows="3" placeholder="Détails facultatifs"></textarea></p>
    <p><label>Échéance</label><br/>
       <input type="date" name="dueDate"></p>
    <p><input type="submit" value="Ajouter"></p>
</form>

<form action="GestionDeTaches.jsp" method="post" onsubmit="return confirm('Effacer toutes les tâches ?');">
    <input type="hidden" name="action" value="clear"/>
    <input type="submit" value="Tout effacer">
</form>

<h2>Mes tâches (<%= tasks.size() %>)</h2>
<% if (tasks.isEmpty()) { %>
    <p>Aucune tâche.</p>
<% } else { %>
<table>
    <tr>
        <th>#</th><th>Titre</th><th>Description</th><th>Échéance</th><th>Statut</th><th>Actions</th>
    </tr>
    <% for (int i = 0; i < tasks.size(); i++) {
           Task t = tasks.get(i);
           boolean done = t.isDone();
    %>
    <tr>
        <td><%= i %></td>
        <td class="<%= done ? "done" : "" %>"><%= t.getTitle() %></td>
        <td class="<%= done ? "done" : "" %>"><%= t.getDescription() %></td>
        <td class="<%= done ? "done" : "" %>"><%= t.getDueDate() %></td>
        <td><%= done ? "Terminée" : "En cours" %></td>
        <td class="actions">
            <!-- Basculer terminé/en cours -->
            <form action="GestionDeTaches.jsp" method="post" style="display:inline;">
                <input type="hidden" name="action" value="toggle"/>
                <input type="hidden" name="index"  value="<%= i %>"/>
                <input type="submit" value="<%= done ? "Remettre en cours" : "Marquer terminée" %>"/>
            </form>
            <!-- Supprimer -->
            <form action="GestionDeTaches.jsp" method="post" style="display:inline;"
                  onsubmit="return confirm('Supprimer cette tâche ?');">
                <input type="hidden" name="action" value="delete"/>
                <input type="hidden" name="index"  value="<%= i %>"/>
                <input type="submit" value="Supprimer"/>
            </form>
        </td>
    </tr>
    <% } %>
</table>
<% } %>
</body>
</html>
