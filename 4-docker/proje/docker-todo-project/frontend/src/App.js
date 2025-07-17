/// FRONTEND (React)

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

export default App;
