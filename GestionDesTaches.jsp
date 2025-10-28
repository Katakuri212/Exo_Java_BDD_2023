<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.*" %>
<%
    // ----- INITIALISATION -----
    request.setCharacterEncoding("UTF-8");

    // On garde la liste dans la session (pas de base de données)
    // Chaque tâche est un tableau [titre, description]
    @SuppressWarnings("unchecked")
    List<String[]> tasks = (List<String[]>) session.getAttribute("tasks");
    if (tasks == null) {
        tasks = new ArrayList<>();
        session.setAttribute("tasks", tasks);
    }

    // ----- AJOUT D'UNE TÂCHE -----
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String title = request.getParameter("title");
        String desc  = request.getParameter("description");
        if (title != null && !title.trim().isEmpty()) {
            tasks.add(new String[]{ title.trim(), desc == null ? "" : desc.trim() });
        }
    }

    // ----- VIDER LA LISTE (optionnel) -----
    if ("clear".equals(request.getParameter("action"))) {
        tasks.clear();
    }

    // Petite fonction d'échappement pour éviter d'afficher du HTML injecté
    String esc(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Tâches (session)</title>
</head>
<body>
<h1>Mes tâches (session)</h1>

<!-- Formulaire d'ajout -->
<form method="post">
    <label>Titre* : <input type="text" name="title" required></label><br><br>
    <label>Description :<br>
        <textarea name="description" rows="4" cols="40"></textarea>
    </label><br><br>
    <button type="submit">Ajouter</button>
    <a href="taches.jsp?action=clear" onclick="return confirm('Vider la liste ?');">Vider la liste</a>
</form>

<hr>

<!-- Liste des tâches -->
<h2>Liste ( <%= tasks.size() %> )</h2>
<% if (tasks.isEmpty()) { %>
    <p>Aucune tâche. Ajoutez-en une ci-dessus.</p>
<% } else { %>
    <ol>
    <%  // Afficher du plus récent au plus ancien
        for (int i = tasks.size() - 1; i >= 0; i--) {
            String[] t = tasks.get(i);
    %>
        <li>
            <strong><%= esc(t[0]) %></strong><br>
            <em><%= t[1].isEmpty() ? "(pas de description)" : esc(t[1]) %></em>
        </li>
    <% } %>
    </ol>
<% } %>

<p style="font-size:12px;color:#555">Données conservées uniquement pendant votre session.</p>
</body>
</html>

