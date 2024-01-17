import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="search-form"
export default class extends Controller {
  search() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
      // Adding another setTimeout for saving final search results for 2 seconds
      clearTimeout(this.timeout2);
      this.timeout2 = setTimeout(() => {
        this.additionalLogicAfterSubmit();
      }, 4000);
    }, 200);
  }

  additionalLogicAfterSubmit() {
    const query = document.getElementById('searchInput').value;
    
    fetch("/searches", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.getElementsByName("csrf-token")[0].content, // Include CSRF token
      },
      body: JSON.stringify({ query: query }),
    })
      .then((response) => response.json())
      .then((data) => {
        // Handle the response if needed
        console.log("Search record created:", data);
      })
      .catch((error) => {
        console.error("Error creating search record:", error);
      });
  }
}
