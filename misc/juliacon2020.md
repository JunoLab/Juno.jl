# JuliaCon 2020 proposal draft

## What to present

NOTE: [Juno 1.0 Project](./juno1.0-project.md) summarizes what we will do for Juno 1.0.

Our current plan of the presentation consists of two parts:

1. Showcase improvements/features (for general users)
- Explain how Juno 1.0 will improve user experiences: easier installation/update and non-interference in user's own environment
- And also we want to showcase lots of features that only we developers know but would be greatly useful for general users: goto/symbols view/refactor/linter, profiler, etc
- This part will be of interest of the majority of possible audiences

2. Describe implementation (for tooling developers)
- In this part, I would like to explain how we solve/implement problems and features; it can help other existing coding environments improve or encourage someone to create another Juno-like tool, or back to our project, attract future contributors and make it easier for them to contribute to Juno
- Possible presentation flow:
  * How to separate Juno packages from user's environment: maybe help julia-vscode extension, for example
  * How to implement linter/refactor using both static code analysis and user runtime info: if we can implement "good" features using information that lives in user's runtime, it will show the benefits of Juno's approach in comparison to an ordinal IDE approach based on static code analysis
- As the above bullet implies, this part will be of much interest of tooling developers

So I think the 2 parts will address interests of the Julia community as a whole.

Each part will take time (say, around 10 min), so I think our presentation form is better to be "Talk" (30 mins long including 5 mins for questions) rather than "Lightning Talk" (10 mins long).

## Body

We need to write title/abstract/description to fulfill a submission.

### Submission title

Juno 1.0 – the powerful IDE has got yet more power !

(53/64 chars)

### Submission type

Talk

### Abstract

We will introduce Juno 1.0 -- show how it will get rid of the longstanding issues and bring us huge productivity boosts.
Juno's unique approach allows IDE features to be implemented simply but yet effectively, using the power of user runtime.

(243/500 chars)

### Description

[Juno](https://junolab.org/) is an IDE for Julia.
It enables unique, powerful and very interactive development style, and has been widely used in the community since its first publication in 2014.
But due to the limitations that comes from its package infrastructure, there also have been some longstanding and fundamental problems, mostly around installation, update, activation time, and interference with user's own package environment.

In this presentation we are going to present Juno 1.0*; explain how it will solve the problems and improve user experiences, and also showcase our latest new features that are being implemented using both static code analysis technique and user's runtime information.

We also plan to describe our approach to solve the difficult problems and implement the new features. Some parts of our approach can be applicable to other development tools and help them improve, as like we actually borrow the efforts devoted to [julia-vscode extension](https://www.julia-vscode.org/) for our static code analysis.

NOTE*: We're writing this 4 months ahead of time; you know, we've not done the work yet ! If you're interested in contribution, hit us on our slack channel. We would really appreciate your help.

(1239/2500 chars)

### Notes (optional)

[Juno 1.0 Project](./juno1.0-project.md) describes our current plan for this project in details.

### Talk image (optional)

![](juno1.0-logo.png)

### Speakers

- Sebastian:
- Shuhei: aviatesk@gmail.com

## Checklist

### title

- [ ] easy to identify the topic of the content ?

### abstract

- [ ] easy to read in English ?
- [ ] understandable for someone not working on the same topic ?

### description

- [ ] the subject should be of interest for JuliaCon ?
- [ ] descriptions are (technically) sound ?

### scoring

1. [ ] applicability to the Julia community ?
2. [ ] contributions to the community ?
3. [ ] clarity: what is the purpose of this talk ? what will people learn ?
4. [ ] significance: change the way a lot of other people use Julia ?
5. [ ] topic diversity
