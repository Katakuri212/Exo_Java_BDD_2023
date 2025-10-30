<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.*, java.time.*, java.time.format.DateTimeParseException, java.io.*, java.util.stream.*" %>
<%-- ======================= LOGIQUE SERVEUR (tout-en-un) ======================= --%>
<%!
    // Modèle de donnée dans la page (OK pour un TP / démo)
    public static class Task implements Serializable {
        private final String id;
        private String title;
        private String description;
        private LocalDate dueDate;
        private boolean done;

        public Task(String title, String description, LocalDate dueDate) {
            this.id = java.util.UUID.randomUUID().toString();
            this.title = title;
            this.description = description;
            this.dueDate = dueDate;
            this.done = false;
        }
        public String getId() { return id; }
        public String getTitle() { return title; }
        public String getDescription() { return description; }
        public LocalDate getDueDate() { return dueDate; }
        public boolean isDone() { return done; }
        public void setTitle(String t){ this.title=t; }
        public void setDescription(String d){ this.description=d; }
        public void setDueDate(LocalDate d){ this.dueDate=d; }
        public void setDone(boolean v){ this.done=v; }
    }

    // Outil d'affichage sûr (éviter balises HTML dans le contenu utilisateur)
    private static String esc(String s){
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    // Récupère/initialise la liste en session
    @SuppressWarnings("unchecked")
    List<Task> tasks = (List<Task>) session.getAttribute("tasks");
    if (tasks == null) {
        tasks = new ArrayList<>();
        session.setAttribute("tasks", tasks);
    }

    // Router minimal via paramètres
    String action = request.getParameter("action");
    String method = request.getMethod(); // "GET" / "POST"

    if ("POST".equalsIgnoreCase(method) && "add".equals(action)) {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String due = request.getParameter("dueDate");
        LocalDate dueDate = null;
        if (due != null && !due.isBlank()) {
            try { dueDate = LocalDate.parse(due); } catch (DateTimeParseException e) { /* ignore */ }
        }
        if (title != null && !title.isBlank()) {
            tasks.add(new Task(title.trim(), description == null ? "" : description.trim(), dueDate));
        }
        // PRG: éviter le re-submit sur F5
        response.sendRedirect(request.getRequestURI());
        return;
    }

    if ("toggle".equals(action)) {
        String id = request.getParameter("id");
        if (id != null) {
            for (Task t : tasks) {
                if (t.getId().equals(id)) { t.setDone(!t.isDone()); break; }
            }
        }
        response.sendRedirect(request.getRequestURI());
        return;
    }

    if ("delete".equals(action)) {
        String id = request.getParameter("id");
        if (id != null) {
            tasks.removeIf(t -> t.getId().equals(id));
        }
        response.sendRedirect(request.getRequestURI());
        return;
    }

    // Optionnel: tri simple via ?sort=due|title|status
    String sort = request.getParameter("sort");
    if (sort != null) {
        Comparator<Task> cmp;
        switch (sort) {
            case "title":
                cmp = Comparator.comparing(t -> Optional.ofNullable(t.getTitle()).orElse(""));
                break;
            case "status":
                cmp = Comparator.comparing(Task::isDone).thenComparing(t -> Optional.ofNullable(t.getTitle()).orElse(""));
                break;
            case "due":
            default:
                cmp = Comparator.comparing((Task t) -> Optional.ofNullable(t.getDueDate()).orElse(LocalDate.MAX))
                        .thenComparing(t -> Optional.ofNullable(t.getTitle()).orElse(""));
        }
        tasks.sort(cmp);
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Gestion de Tâches — Single JSP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        :root{--fg:#222;--muted:#666;--b:#e9e9ef;--acc:#0a84ff;--ok:#0a0;--warn:#aa8c00;--bg:#fff}
        *{box-sizing:border-box}
        body{font-family:system-ui,Segoe UI,Roboto,Arial,sans-serif;margin:32px;color:var(--fg);background:var(--bg)}
        h1{margin:0 0 10px}
        .wrap{max-width:980px;margin:0 auto}
        .card{border:1px solid var(--b);border-radius:12px;padding:16px;margin:16px 0;background:#fff}
        label{display:block;margin-top:10px;font-weight:600}
        input[type=text], textarea, input[type=date]{
            width:100%;padding:10px;border:1px solid var(--b);border-radius:8px;margin-top:6px
        }
        .row{display:flex;gap:10px;flex-wrap:wrap;align-items:center}
        .btn{padding:10px 14px;border:1px solid var(--b);border-radius:8px;background:#f7f7f9;cursor:pointer;text-decoration:none;color:inherit}
        .btn.primary{border-color:var(--acc);outline:1px solid var(--acc)}
        .btn.danger{border-color:#d33;color:#b00}
        table{border-collapse:collapse;width:100%}
        th,td{border-bottom:1px solid var(--b);padding:10px;text-align:left;vertical-align:top}
        th{background:#fafafa}
        .badge{padding:2px 8px;border-radius:999px;border:1px solid var(--muted);font-size:12px}
        .done{background:#eaffea;border-color:#0a0;color:#060}
        .pending{background:#fff8e6;border-color:var(--warn);color:#7a5}
        .muted{color:var(--muted)}
        .topbar{display:flex;justify-content:space-between;gap:10px;align-items:center;margin:8px 0 16px}
        .filters a{margin-right:8px}
        .empty{padding:16px;border:1px dashed var(--b);border-radius:10px}
    </style>
</head>
<body>
<div class="wrap">
    <div class="topbar">
        <h1>Mini Gestionnaire de Tâches (une seule JSP)</h1>
        <div class="filters">
            <span class="muted">Trier :</span>
            <a class="btn" href="?sort=due">Échéance</a>
            <a class="btn" href="?sort=title">Titre</a>
            <a class="btn" href="?sort=status">Statut</a>
        </div>
    </div>

    <div class="card">
        <h2>Ajouter une tâche</h2>
        <form method="post">
            <input type="hidden" name="action" value="add"/>
            <label>Titre
                <input type="text" name="title" required />
            </label>
            <label>Description
                <textarea name="description" rows="3"></textarea>
            </label>
            <label>Échéance
                <input type="date" name="dueDate" />
            </label>
            <div class="row" style="margin-top:12px">
                <button class="btn primary" type="submit">Enregistrer</button>
                <button class="btn" type="reset">Réinitialiser</button>
            </div>
        </form>
    </div>

    <div class="card">
        <h2>Mes tâches</h2>
        <%
            if (tasks.isEmpty()) {
        %>
            <div class="empty">Aucune tâche pour le moment. Ajoute-en une ci-dessus.</div>
        <%
            } else {
        %>
        <table>
            <thead>
            <tr>
                <th style="width:22%">Titre</th>
                <th style="width:38%">Description</th>
                <th style="width:15%">Échéance</th>
                <th style="width:10%">Statut</th>
                <th style="width:15%">Actions</th>
            </tr>
            </thead>
            <tbody>
            <%
                for (Task t : tasks) {
                    String dueText = (t.getDueDate()==null) ? "—" : t.getDueDate().toString();
            %>
                <tr>
                    <td><%= esc(t.getTitle()) %></td>
                    <td><%= esc(t.getDescription()) %></td>
                    <td><%= dueText %></td>
                    <td>
                        <% if (t.isDone()) { %>
                            <span class="badge done">Terminée</span>
                        <% } else { %>
                            <span class="badge pending">En cours</span>
                        <% } %>
                    </td>
                    <td class="row" style="gap:6px">
                        <a class="btn" href="?action=toggle&id=<%= t.getId() %>">Basculer</a>
                        <a class="btn danger" href="?action=delete&id=<%= t.getId() %>"
                           onclick="return confirm('Supprimer cette tâche ?');">Supprimer</a>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

    <p class="muted">Stockage: session HTTP (ArrayList&lt;Task&gt;). Aucun servlet ni base de données.</p>
</div>
</body>
</html>

