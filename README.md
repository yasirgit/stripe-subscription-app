# README

# Stripe Subscription App

This is a Ruby on Rails application that implements Stripe subscriptions. It's containerized using Docker for easy setup and development.

## Running the Application

### Prerequisites
- Docker and Docker Compose installed on your system

### Steps

1. **Build the Docker image:**
```sh
docker-compose build
```

2. **Start the Rails server:**
```sh
docker-compose up
```

3. **Create the database (first time only):**
```sh
docker-compose run web rails db:create
```

4. **Run migrations:**
```sh
docker-compose run web rails db:migrate
```

5. **Access the Rails console:**
```sh
docker-compose run web rails console
```

6. **Rebuild the image** (if changes are made to the Dockerfile or Gemfile):
```sh
docker-compose build
```


## Running Unit Tests

To run the unit tests, use the following command:
```sh
rspec
```

<img width="1091" alt="Screenshot 2024-12-12 at 13 10 04" src="https://github.com/user-attachments/assets/ee0ad37a-0cf7-4738-b38f-9367f2df20eb" />



## Setting up ngrok for Webhook Testing

ngrok allows you to expose your local development server to the internet, which is useful for testing Stripe webhooks.

### Installation

- **MacOS:**
```sh
brew install ngrok
```

- **Linux:**
Use your distribution's package manager (e.g., `apt` for Ubuntu)
- **Windows:**
```sh
choco install ngrok
```


### Configuration

1. Create an ngrok account and get your authtoken from the ngrok dashboard.

2. Connect your ngrok agent to your account:
```sh
ngrok config add-authtoken <AUTHTOKEN>
```

3. In a new terminal window, start ngrok:
```sh
ngrok http 3000
```


3. Copy the ngrok URL (e.g., `https://6a55-2a02-908-1871-6ee0-1d8c-a83b-f83f-8ba9.ngrok-free.app`).

<img width="1091" alt="Screenshot 2024-12-12 at 12 38 56" src="https://github.com/user-attachments/assets/bc002c1c-5e5d-4339-a5b5-216febb91533" />


4. Log in to your Stripe Dashboard and go to Developers > Webhooks.

5. Click "Add endpoint" and enter your ngrok URL followed by the webhook route (e.g., `https://6a55-2a02-908-1871-6ee0-1d8c-a83b-f83f-8ba9.ngrok-free.app/webhooks/stripe`).

Now you can test Stripe webhooks with your local development server.







