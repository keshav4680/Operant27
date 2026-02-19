from flask import Flask, jsonify, request, render_template_string
from datetime import datetime
import os

app = Flask(__name__)

# In-memory storage for demo
tasks = []

HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>Learnbay DevOps Demo</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        h1 { color: #2c3e50; }
        .task { background: #ecf0f1; padding: 10px; margin: 10px 0; border-radius: 5px; }
        input, button { padding: 10px; margin: 5px; }
        button { background: #3498db; color: white; border: none; cursor: pointer; }
        button:hover { background: #2980b9; }
        .info { background: #e8f5e9; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>🚀 Learnbay DevOps Demo App</h1>
    <div class="info">
        <p><strong>Hostname:</strong> {{ hostname }}</p>
        <p><strong>Time:</strong> {{ time }}</p>
    </div>
    <h2>Task Manager</h2>
    <div>
        <input type="text" id="taskInput" placeholder="Enter a task">
        <button onclick="addTask()">Add Task</button>
    </div>
    <div id="tasks"></div>
    <script>
        function loadTasks() {
            fetch('/api/tasks')
                .then(r => r.json())
                .then(data => {
                    document.getElementById('tasks').innerHTML = data.tasks
                        .map(t => `<div class="task">${t.id}. ${t.name} - ${t.created}</div>`)
                        .join('');
                });
        }
        function addTask() {
            const task = document.getElementById('taskInput').value;
            if (!task) return;
            fetch('/api/tasks', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({name: task})
            }).then(() => {
                document.getElementById('taskInput').value = '';
                loadTasks();
            });
        }
        loadTasks();
    </script>
</body>
</html>
'''

@app.route('/')
def home():
    return render_template_string(
        HTML_TEMPLATE,
        hostname=os.getenv('HOSTNAME', 'localhost'),
        time=datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    )

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})

@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    return jsonify({'tasks': tasks})

@app.route('/api/tasks', methods=['POST'])
def add_task():
    data = request.get_json()
    task = {
        'id': len(tasks) + 1,
        'name': data.get('name'),
        'created': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }
    tasks.append(task)
    return jsonify(task), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)