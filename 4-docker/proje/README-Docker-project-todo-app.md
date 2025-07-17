# 🐳 Docker Capstone Projesi: Todo Uygulaması

Bu proje, Docker'ı yeni öğrenenlerin hem teorik bilgilerini pekiştirmeleri hem de gerçek bir uygulamayı Dockerize ederek yetkinliklerini geliştirmeleri amacıyla hazırlanmıştır. Projede bir **frontend** ve bir **backend** uygulaması bulunmaktadır. Uygulamanın amacı basit bir **Todo Listesi** işlevi görmektir.

---

## 📌 Proje Özeti

- Frontend: React tabanlı kullanıcı arayüzü  
- Backend: Node.js + Express.js ile REST API  
- Veritabanı: JSON tabanlı mock veri (ekstra DB kurulumu yok)  
- Docker ile:
  - Frontend ve backend ayrı konteynerlerde çalıştırılacak
  - Docker Compose ile tek komutla ortam kurulacak
  - Ortam değişkenleri ile yapılandırma sağlanacak

---

## 📚 İçerik Başlıkları (Outline)

1. Proje Klasör Yapısının Oluşturulması  
2. Backend (Node.js) Uygulamasının Yazılması  
3. Frontend (React) Uygulamasının Oluşturulması  
4. Her bileşen için Dockerfile hazırlanması  
5. Docker Compose dosyası ile servislerin birleştirilmesi  
6. Uygulamanın Docker ile çalıştırılması  
7. Tarayıcı üzerinden test edilmesi  

---

## 1️⃣ Proje Yapısını Oluşturma

```bash
mkdir docker-todo-project
cd docker-todo-project
mkdir backend frontend
```

Bu klasör yapısı frontend ve backend bileşenlerini ayrı yönetmemizi sağlar.
todo-app/
├── frontend/
│ ├── Dockerfile
│ └── src/App.js
│
├── backend/
│ ├── Dockerfile
│ └── index.js
├── docker-compose.yml
└── README.md
---

## 2️⃣ Backend Uygulamasını Oluşturma (Node.js)

`backend/` klasörüne giriyoruz:

```bash
cd backend
npm init -y
npm install express cors
```

Ardından `index.js` dosyası oluşturun:

```js
echo '/// BACKEND (Node.js + Express)

// backend/index.js
const express = require("express");
const cors = require("cors");
const { v4: uuidv4 } = require("uuid");

const app = express();
app.use(cors());
app.use(express.json());

let todos = [];

app.get("/todos", (req, res) => res.json(todos));

app.post("/todos", (req, res) => {
  const todo = { id: uuidv4(), text: req.body.text };
  todos.push(todo);
  res.status(201).json(todo);
});

app.delete("/todos/:id", (req, res) => {
  const { id } = req.params;
  const index = todos.findIndex(t => t.id === id);
  if (index !== -1) {
    todos.splice(index, 1);
    res.sendStatus(204);
  } else {
    res.status(404).json({ error: "Todo not found" });
  }
});

app.put("/todos/:id", (req, res) => {
  const { id } = req.params;
  const todo = todos.find(t => t.id === id);
  if (todo) {
    todo.text = req.body.text;
    res.json(todo);
  } else {
    res.status(404).json({ error: "Todo not found" });
  }
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`Backend running on port ${PORT}`));' > index.js
```

### ✅ Dockerfile Oluşturma

```Dockerfile
# backend/Dockerfile
echo 'FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install && npm install uuid
COPY . .

EXPOSE 4000
CMD ["node", "index.js"]' > Dockerfile
```

---

## 3️⃣ Frontend Uygulamasını Oluşturma (React)

```bash
cd ../frontend
npx create-react-app . -y

```

`src/App.js` içeriğini şu şekilde güncelleyin:

```js
echo '/// FRONTEND (React)

// src/App.js
import { useEffect, useState } from "react";
import "./App.css";

function App() {
  const [todos, setTodos] = useState([]);
  const [text, setText] = useState("");

  useEffect(() => {
    fetch("http://localhost:4000/todos")
      .then(res => res.json())
      .then(setTodos);
  }, []);

  const addTodo = async () => {
    const newTodo = { text };
    const res = await fetch("http://localhost:4000/todos", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(newTodo)
    });
    const data = await res.json();
    setTodos([...todos, data]);
    setText("");
  };

  const deleteTodo = async (id) => {
    await fetch(`http://localhost:4000/todos/${id}`, { method: "DELETE" });
    setTodos(todos.filter(todo => todo.id !== id));
  };

  const updateTodo = async (id, newText) => {
    const res = await fetch(`http://localhost:4000/todos/${id}`, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text: newText })
    });
    if (res.ok) {
      setTodos(todos.map(todo => todo.id === id ? { ...todo, text: newText } : todo));
    }
  };

  return (
    <div className="app">
      <h1>Todo Listesi</h1>
      <input
        value={text}
        onChange={e => setText(e.target.value)}
        placeholder="Yeni todo girin"
        style={{ padding: "8px", borderRadius: "4px" }}
      />
      <button
        onClick={addTodo}
        style={{ backgroundColor: "#4CAF50", color: "white", padding: "10px", margin: "5px", borderRadius: "4px" }}
      >Ekle</button>

      <ul>
        {todos.map(todo => (
          <li key={todo.id} style={{ margin: "5px 0", padding: "8px", backgroundColor: "#f4f4f4", borderRadius: "4px", display: "flex", justifyContent: "space-between" }}>
            {todo.text}
            <div>
              <button
                onClick={() => updateTodo(todo.id, prompt("Yeni todo: ", todo.text))}
                style={{ backgroundColor: "#FFA500", color: "white", padding: "5px", borderRadius: "4px", marginRight: "5px" }}
              >Güncelle</button>
              <button
                onClick={() => deleteTodo(todo.id)}
                style={{ backgroundColor: "#f44336", color: "white", padding: "5px", borderRadius: "4px" }}
              >Sil</button>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;' > src/App.js
```

### ✅ Frontend için Dockerfile

```Dockerfile
# frontend/Dockerfile
echo 'FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

EXPOSE 3000
CMD ["npm", "start"]' > Dockerfile
```

---
### ✅ Frontend için BONUSSSS Dockerfile
<!-- 
```Dockerfile
# frontend/Dockerfile
echo 'FROM node:18-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# 2. Aşama: Serve with nginx
FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]' > Dockerfile
```
 -->



## 4️⃣ Docker Compose Dosyasını Oluşturma

Proje ana dizinine `docker-compose.yml` dosyasını ekleyin:
```bash
cd .. # ana dizine geçin
```

```yaml
# docker-compose.yml
echo 'version: "3"

services:
  backend:
    build: ./backend
    ports:
      - "4000:4000"

  frontend:
    build: ./frontend
    ports:
      - "3000:3000" # bonus dackerfile kullanırsan - "3000:80"
    depends_on:
      - backend' > docker-compose.yml
```

---

## 5️⃣ Uygulamanın Çalıştırılması

```bash
docker compose up --build -d
```

Bu komut her iki uygulamayı da build eder ve ayağa kaldırır.

---

## 🔍 Tarayıcı Üzerinden Test

Tarayıcınızdan `http://localhost:3000` adresine giderek Todo uygulamasını test edebilirsiniz. Yazdığınız her yeni todo, backend'e kaydedilecektir (RAM içinde tutulur).

---

## 🧹 Servisi Durdurmak

```bash
docker compose down
```

---

## 🎯 Öğrendiklerimiz

- Frontend ve Backend için ayrı Dockerfile yazımı  
- Docker Compose ile çoklu servis yönetimi  
- Port yönlendirme, container isimlendirme  
- Ortam değişkenleri ve servisler arası iletişim  

---

Bu capstone proje, Docker konusunda pratik kazanmak isteyen geliştiriciler için temel düzeyde uçtan uca bir uygulamayı kapsar. Gerçek projelerde benzer yapıların nasıl kurulacağını deneyimlemiş olursunuz.
