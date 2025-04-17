# Smart Budget App

## Table of Contents

1. [Overview](#Overview)
2. [Product Spec](#Product-Spec)
3. [Wireframes](#Wireframes)
4. [Schema](#Schema)

## Overview

### Description

Smart Budget App is a modern finance tracker that allows users to record their expenses, create shared budget plans with friends through an intuitive split-payment feature, and gain valuable insights with AI-powered spending analysis to stay financially organized.

### App Evaluation

- **Category:** Lifestyle
- **Mobile:** Mobile is essential for real-time expense tracking and quick updates on the go. Users can instantly log purchases, receive spending alerts, and manage group expenses from their phones. Mobile notifications also remind users of budget limits, upcoming bills, or unusual spending patterns.
- **Story:** Managing money shouldn’t be complicated or lonely. This app empowers users to take charge of their finances with ease and transparency, whether budgeting solo or sharing expenses with friends or roommates. By providing personalized AI insights, it helps users build healthy financial habits while staying informed and in control.
- **Market:** Ideal for students, young professionals, and anyone looking to manage day-to-day expenses. Great for roommates, couples, or travel groups who need to split bills fairly. Monetization can come from premium features like smart financial forecasts, export options.
- **Habit:** Users interact with the app regularly to log expenses and review their budget progress. Users can engage with the built-in AI assistant whenever they need money-saving tips or spending advice, making it a helpful on-demand financial companion rather than a push-based tool.
- **Scope:** V1 would finish core features include signup/login, personal expense tracking, budget creation. V2 would implement split-payment plans with invite system, shared budget tracking, and expense reconciliation. V3 would integrate with the OpenAI API to provide AI-generated spending insights and savings suggestions. V4 would add optional notification system to alert users when they approach or exceed their budget limits.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* When Vivian wants to keep track of her spending, she opens the Smart Budget App and creates an account. During sign-up, she is prompted (optionally) to set a monthly budget. Once registered, she can immediately begin logging expenses. Each expense entry includes the category, amount, and date, helping her stay organized and mindful of her spending habits.
* When Vivian goes on a trip with her friend Cameron, she invites Cameron to join the Smart Budget App. After Cameron signs up, he becomes a registered user and can be added to a shared spending group. During the trip, both Vivian and Cameron contribute to the group’s expense log. The app automatically calculates the balances, letting them know who owes whom and how much, making group expenses hassle-free.


**Optional Nice-to-have Stories**

* At one point, Vivian feels like she has been overspending and wants to understand which category is pushing her over budget. She opens the in-app AI chatbot and asks for a spending analysis. The AI assistant responds with a breakdown of her spending by category, helping her identify areas where she can cut back.
* As a returning user, Vivian receives a notification one day that her transport spending has exceeded her usual limit. After seeing the alert, she decides to skip ordering another Uber and instead uses public transportation, making a more budget-friendly decision.

### 2. Screen Archetypes

- [ ] Sign Up
* Vivian can create a new account to start using the Smart Budget App.
- [ ] Sign In
* Vivian can securely log back into her account to access her personal and group budget data.
- [ ] Profile
* Display User Id, User Name, Email
- [ ] My Budget
* Vivian can tap to edit or delete any of her previously recorded expenses.
* Vivian can left swip to delete any of her previously recorded expenses.
* Vivian sees a visual Pie Chart that summarizes her expenses by category, helping her understand where her money is going.
* Vivian can filter her expense records by date to view spending over a specific time range.
- [ ] Add Expense
* Vivian can log her personal expenses by selecting a category, entering the amount, and setting the date.
- [ ] Spending Groups
* Vivian can view all groups that she has joined
- [ ] Group Details
* Vivian can create a shared spending group and invite friends to join using their registered accounts.
* Each group member can view a breakdown of shared expenses and see how much they owe or are owed by other members.
* Group members can edit or delete their own expense entries within the group to ensure accuracy.
- [ ] Add Group Expense
* Each group member can add new expense with title, amount, and select who pay for it
- [ ] AI Assistant (OPTIONAL)
* Vivian can use a chatbot to ask for spending advice. 

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* My Budget
* Spending Groups
* Profile
* AI Assistant (OPTIONAL)

**Flow Navigation** (Screen to Screen)

- [ ] Sign Up
* Sign In
- [ ] Sign In Page
* Sign Up
* My Budget
- [ ] My Budget
* Add Expense
- [ ] Spending Groups
* Group Details
- [ ] Group Details
* Add Group Expense


## Wireframes

### Digital Wireframes & Mockups
<img src="https://i.postimg.cc/KzSq2gSg/Screenshot-2025-04-16-at-12-08-41-PM.png" width=600>
<img src="https://i.postimg.cc/7hXm0sCg/Screenshot-2025-04-16-at-12-08-48-PM.png" width=600>
<img src="https://i.postimg.cc/7hqKC8LH/Screenshot-2025-04-16-at-12-09-37-PM.png" width=600>

### Interactive Prototype
[Prototype Link](https://www.figma.com/proto/yH01ZdKka31RWoThjWFa4y/smart-budget-app?node-id=8-1114&t=TFwcKOOQDYJr0xkB-1&scaling=scale-down&content-scaling=fixed&page-id=0%3A1)

## Schema 

[This section will be completed in Unit 9]

### Models

[Add table of models]

### Networking

- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
