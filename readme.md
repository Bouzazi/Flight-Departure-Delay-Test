
# Flight Departure Delay API

## Introduction

The solution consists of a backend API built with Ruby on Rails and a frontend user interface built with React. The API fetches flight departure and delay data from the data providers, processes it, and delivers the information via differet endpoints. The frontend provides a user-friendly interface to browse the flights information.

## Starting the Project
### Backend

1. Ensure you have Ruby, Bundler, and PostgreSQL installed on your machine.
2. Navigate to the `backend` directory.
3. Install the required gems:
   ```sh
   bundle install
   ```
4. Set up the database:
   ```sh
   rails db:create db:migrate db:seed
   ```
5. Start the Rails server:
   ```sh
   rails server
   ```

The backend server will start at `http://localhost:3000`.

### Frontend

The frontend is a React application that allows users to browse the flight information provided by the backend API.
It uses Tailwind CSS components to provide a modern and responsive user interface.

1. Ensure you have Node.js and Yarn installed on your machine.
2. Navigate to the `frontend` directory.
3. Install the required packages:
   ```sh
   yarn install
   ```
4. Start the React development server:
   ```sh
   yarn start
   ```

The frontend server will start at `http://localhost:3000`.

## With Docker Compose

1. Ensure you have Docker and Docker Compose installed on your machine.
2. Navigate to the project root directory.
3. Run the following command to start both services:
   ```sh
   docker-compose up --build
   ```

## Testing
### Backend Tests

The backend includes tests to ensure the API is functioning correctly. To run the tests, navigate to the `backend` directory and execute the following command:
   ```sh
   rails test
   ```