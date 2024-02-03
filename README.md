```
 .----------------.  .----------------.  .----------------.  .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
| |    _______   | || |  _________   | || |      __      | || |  _______     | || |     ______   | || |  ____  ____  | |
| |   /  ___  |  | || | |_   ___  |  | || |     /  \     | || | |_   __ \    | || |   .' ___  |  | || | |_   ||   _| | |
| |  |  (__ \_|  | || |   | |_  \_|  | || |    / /\ \    | || |   | |__) |   | || |  / .'   \_|  | || |   | |__| |   | |
| |   '.___`-.   | || |   |  _|  _   | || |   / ____ \   | || |   |  __ /    | || |  | |         | || |   |  __  |   | |
| |  |`\____) |  | || |  _| |___/ |  | || | _/ /    \ \_ | || |  _| |  \ \_  | || |  \ `.___.'\  | || |  _| |  | |_  | |
| |  |_______.'  | || | |_________|  | || ||____|  |____|| || | |____| |___| | || |   `._____.'  | || | |____||____| | |
| |              | || |              | || |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 

```
# Search Box

This project is a Real-time search box, where users search articles by title and body and have analytics that display what users were searching for.  users are tracked via IP.

## Table of Contents

- [Tools & Technologies](#tools-and-technologies)
- [controllers](#controllers)
- [Search engine logic](#search-engine-logic)
- [Sidekiq Job](#sidekiq-job)
- [Installation](#installation)
- [Demo](#demo)

## Tools and Technologies

- Ruby: 3.2.2
- Rails: 7.1.2
- postgreSQL: 15.5
- Redis: 7.2.4
- Bootstrap: 4.4.1
- Sidekiq
- Docker & Docker compose

## Controllers

**In `application_controller.rb`:**

This controller defines a method `current_user` and sets it as a helper method using `helper_method :current_user`, It checks if the "X-Forwarded-For" header is present in the request. This header is often used in proxy configurations to pass along the original client's IP address.

- It checks if the "X-Forwarded-For" header is present in the request. This header is often used when requests pass through proxy servers. If present, it extracts the first IP address from the comma-separated list of addresses. If not present, it falls back to the request.remote_ip, which gives the IP address of the client making the request.

- The `current_user ||= User.find_or_create_by(ip: ip)` line ensures that the `current_user` is memoized, meaning it won't perform the database query on subsequent calls within the same request cycle if `current_user` has already been set.

Note: This implementation assumes that users are uniquely identified by their IP addresses. not as multiple users can share the same IP address (e.g., users behind a corporate firewall or using the same Wi-Fi network).

<hr>

**In `articles_controller.rb`:**

**Index Action:** The index action is responsible for listing articles.
-If a search query `params[:query]` is present, it filters articles based on the title or body using a `SQL LIKE` query.

-If no search query is provided, it fetches all articles.

**New Action:** The new action is used to display a form for creating a new article.

- It initializes a new Article object for use in the form.

**Create Action:** The create action handles the creation of a new article.

- It initializes a new Article object with the parameters from the form `article_params`.

- If the article is successfully saved, it sets a flash notice and redirects to the newly created article's show page.

- If the article fails to save, it re-renders the 'new' template with an HTTP status code of `unprocessable_entity`.

**Private Method article_params**

- This method defines strong parameters for the article, allowing only the specified attributes (title and body) to be mass-assigned.
<hr>

**In `searches_controller.rb`:**

**Index Action:** The index action appears to be used for displaying a list of searches and their counts.

- It groups searches by the query, orders them by the count in descending order, and retrieves the count for each unique query.

**Get History Action:** The get_history action retrieves and displays the search history of the current user.

- It orders the searches by creation date in descending order.

**New Action:** The new action is used to display a form for creating a new search.

- It initializes a new Search object for use in the form.

**Create Action:** The create action handles the creation of a new search.

- It initializes a new Search object with the parameters from the form `search_params`.

- It associates the search with the current user `@search.user = current_user`.

- If the search is successfully saved, nothing happens (implicit rendering). If it fails to save, it re-renders the 'new' template with an HTTP status code of `unprocessable_entity`.

**Private Method `search_params`:**

- This method defines strong parameters for the search, allowing only the specified attribute `query` to be mass-assigned.
<hr>

## Search engine logic

**In `search_form_controller.js`**

This is a Stimulus controller written in JavaScript. Stimulus is a JavaScript framework that enhances the interactivity of web pages by adding controllers to HTML elements. 

**search Method:** This method is called when the search-form controller is triggered in `articles/index.html.erb` file.

- It uses setTimeout to introduce a delay before triggering the search. The purpose of this delay is to wait for user input to settle before initiating the search action.

- The `clearTimeout(this.timeout)` is used to clear any previous timeouts to avoid stacking multiple timeouts.

- Inside the setTimeout callback: `this.element.requestSubmit();` triggers the form submission.

- Another setTimeout is used to introduce a delay of 4 seconds (4000 milliseconds) before calling `this.additionalLogicAfterSubmit()`. 

**`additionalLogicAfterSubmit` Method:**  This method is called after the form is submitted, and the additional logic is executed.

- It retrieves the search query from the input field with the id searchInput.

- It uses the Fetch API to make a POST request to the "/searches#create" endpoint which includes the search query in the request body as JSON.

- The X-CSRF-Token header is set to the CSRF token to protect against cross-site request forgery.
<hr>

## Sidekiq Job

To optimize the handling of a large volume of search results and ensure efficient processing, I am considering leveraging the robust capabilities of Sidekiq, a powerful background job processing library. Instead of burdening the controller with creating and saving search results, I propose offloading this operation to Sidekiq. This approach allows for asynchronous processing, enhancing the overall performance and responsiveness of the application.

**In `config/initializers/sidekiq.rb`**:

`Sidekiq.strict_args!(false):` This configuration sets strict_args to false, which means Sidekiq will not enforce strict argument checking for my background jobs. It allows me to pass non-serializable objects or complex data structures as arguments to my Sidekiq workers, like `search_params` in our case.

`Sidekiq.configure_server` and `Sidekiq.configure_client`: Configuring the Redis connection for both the server and client, with the Redis server located at `redis://redis:6379/1`.

**In `controllers/searches_controller.rb`**:

enqueuing a background job using Sidekiq in create action. The job, named SaveSearchJob, is tasked with performing some operations asynchronously. Here is a breakdown of what your code is doing:

`search_params.to_h`: Converts the `search_params` into a hash. because `search_params` is an instance of ActionController::Parameters.

`SaveSearchJob.perform_async(...)`: Enqueues the SaveSearchJob background job to Sidekiq. The perform_async method is used to push the job onto the Sidekiq queue.

**In `sidekiq/save_search_job.rb`**:

This setup ensures that the search is associated with the correct user and is saved to the database. If any issues occur during the save operation, it will be logged, and the exception will be re-raised to notify Sidekiq about the failure. Ensure that your User and Search models are defined correctly and have the necessary associations.

`User.find_by(id: user_id)`: Retrieves the User instance based on the user_id.

`Search.new(search_params)`: Creates a new Search instance with the provided search_params.

`@search.user = current_user`: Associates the created Search instance with the current_user.

`@search.save!`: Attempts to save the Search instance to the database. The use of save! will raise an exception if the save operation fails.

`rescue StandardError => e`: Catches any exceptions that may occur during the save operation.

`Rails.logger.error("SaveSearchJob failed: #{e.message}")`: Logs an error message if the save operation fails. This is helpful for debugging and monitoring.

`raise e`: Re-raises the exception after logging, ensuring that Sidekiq will mark the job as failed.
<hr>

## Installation

Build the Docker compose image by the following command.
```bash
docker compose build
```
 <br>

Create a Docker containers the following commad.
```bash
docker compose up
```
<hr>

## Demo

[Search box live link ](https://search-box-husseinelgammal.koyeb.app/)
