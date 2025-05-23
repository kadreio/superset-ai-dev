We are going to create a plan for a feature. This plan will include all context needed, any outstanding product or feature questions that need more investigation, and an explicit task list of things to do.

The feature we're planning for:

$ARGUMENTS


The template is as follow:

---

Created Date <Today's Date>

# Feature Plan: <title>

# Overview

<Context on why we're making this feature, and what it's looking to achieve>

# Outcomes

<a bulleted list things that we want to achieve with this plan>

# Open Questions

<A checkmarkable list of open questions we should resolve before starting the plan, after receiving the feedback from the user on the questions, we will checkmark the question as done, and include the answer below it. Example:

[ ] Do we have a perference on using stdlib versus a dependancy

[x] What Metrics do we need to collect

CPU, Memory, and average response time

>

# Tasks

<A thorough list of checkmarkable tasks that need to be completed in order to achieve the plan: EG

[ ] Define API Interface for the new endpoint using swagger

[ ] Create tests for the new endpoint

[ ] Implement database migrations

[ ] Create DAOs

[ ] Create Seeders

[ ] Implement business logic between endpoint router and DAO

[ ] Implement endpoint and swagger

>

# Security

<Parts of the implementation we need to consider especially for security ramifications>

# <Other sections as make sense for the implementation, including schemas, diagrams, or other concerns>
