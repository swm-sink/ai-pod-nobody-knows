# Episode 4: AI Went to School on the Internet (Bad Idea)

In twenty sixteen, Microsoft launched an AI chatbot named Tay designed to learn from conversations with people on Twitter. Within twenty-four hours, internet users had taught it to spout conspiracy theories and offensive language so extreme that Microsoft had to shut it down completely. <break time="0.5s" /> This wasn't a malfunction—it was artificial intelligence working exactly as designed, learning from the data humans provided.

Welcome back to Nobody Knows. We've explored expert uncertainty, the mystery of pattern recognition, and the enormous costs of AI development. Today, we're tackling the most fundamental question in artificial intelligence: what happens when you teach a system to learn from everything humans have ever written online?

This episode is for anyone who's ever wondered why AI sometimes gives biased, inappropriate, or just plain wrong answers. Instead of treating these as technical glitches, we're exploring how they reveal something profound about both artificial intelligence and human nature.

By the end of this episode, you'll understand why training AI on internet data was simultaneously the best and worst decision in the history of machine learning, and you'll have insight into where AI behavior really comes from.

Let's start with the scale of what we're talking about. Modern large language models like GPT-4 and Claude are trained on datasets containing trillions of words—essentially everything publicly available on the internet, plus digitized books, academic papers, news articles, and reference materials.

This represents the largest collection of human knowledge and expression ever assembled. It includes Wikipedia articles written by subject matter experts, scientific papers from leading researchers, literary classics, historical documents, and educational materials covering every conceivable topic.

But it also includes comment sections, social media posts, conspiracy theories, hate speech, misinformation, spam, and the digital equivalent of bathroom graffiti. The internet contains humanity's greatest achievements and our most embarrassing moments, side by side, with no warning labels.

For AI systems that learn by finding patterns in data, this creates an unprecedented challenge: how do you extract wisdom from a dataset that contains both Nobel Prize-winning research and flat-earth conspiracy theories?

The answer is: you can't, not completely. AI systems trained on internet data learn to reproduce the full spectrum of human communication, including the parts we'd rather forget.

This isn't a design flaw—it's an inevitable consequence of how these systems work. Remember, AI doesn't understand the content it's processing. It sees statistical patterns in text without comprehending truth, falsehood, helpfulness, or harm.

When an AI system encounters thousands of examples of a particular type of language or perspective, it learns that those patterns are common and begins incorporating them into its own responses. It doesn't evaluate whether those patterns represent good ideas, accurate information, or appropriate communication.

This process amplifies whatever biases exist in the training data. If the internet contains more examples of men described as engineers and women described as nurses, the AI learns to associate those patterns. If historical texts consistently describe certain groups in stereotypical ways, those stereotypes become embedded in the system's pattern recognition.

The amplification happens because AI systems don't just passively absorb these patterns—they actively use them to generate new text. When asked about careers, the system might default to gender stereotypes not because it was programmed to discriminate, but because those were the strongest statistical patterns in its training data.

This creates what researchers call "bias amplification"—AI systems that don't just reflect human biases but potentially make them more systematic and widespread.

The challenge gets worse when you consider that internet data isn't representative of human diversity. English-language content dominates, creating systems that work better for English speakers. Content from wealthier countries and demographics is overrepresented. Academic and professional perspectives are more common than working-class viewpoints.

Even within English-language content, certain perspectives are dramatically overrepresented. The people most likely to write extensively online—and thus contribute large amounts of training data—tend to be younger, more educated, more technically savvy, and more politically engaged than the general population.

This skewed representation means AI systems often reflect the biases and blind spots of their most prolific data contributors, rather than balanced human perspectives.

But here's where it gets really complicated: there's no obvious alternative approach that would solve these problems.

Manually curating training data would be impossible at the scale required for advanced AI systems. Human reviewers can't read and evaluate trillions of words of text. Even if they could, who would decide what content is appropriate or accurate? What criteria would they use? Whose values would guide those decisions?

Automated filtering systems create their own problems. If you remove all controversial content, you eliminate important discussions about complex social and political issues. If you filter out informal language, you lose the diversity of human communication styles. If you only include "high-quality" sources, you create systems that sound academic but can't relate to everyday human experience.

Different filtering approaches produce AI systems with different characteristics and blindspots. There's no neutral or objective way to curate human knowledge and expression.

You know what? Describing this as a curation problem makes it sound like a librarian's challenge, but it misses the fundamental issue. Think of it more like trying to raise a child by having them read every book ever written—including the good ones, the terrible ones, the fiction, the propaganda, and everything in between—all at the same time, with no guidance about which ideas are worth adopting. The child would learn an enormous amount about human expression and knowledge, but they'd also absorb every misconception, bias, and harmful idea humans have ever written down.

This connects to our previous discussions about pattern recognition without understanding, and helps explain why AI systems can be simultaneously incredibly knowledgeable and problematically biased.

The "raising a child" analogy also highlights why this problem is so difficult to solve. Human children learn to navigate conflicting information through years of guidance, experience, and social feedback. They develop judgment about which sources to trust and which ideas make sense in different contexts.

AI systems don't have that developmental process. They encounter all human knowledge simultaneously, without the contextual learning that helps humans distinguish between reliable and unreliable information.

This explains why modern AI companies invest so heavily in what they call "alignment" research—techniques for helping AI systems behave more helpfully and harmlessly despite being trained on problematic data.

One approach is reinforcement learning from human feedback, where human trainers rate AI responses and the system learns to produce outputs that humans prefer. This helps reduce some of the most obviously harmful or biased responses.

Another technique is constitutional AI, where systems are trained to follow a set of principles that guide their behavior, similar to how a human might try to follow ethical guidelines even when exposed to harmful ideas.

Companies also use content filtering and safety measures to prevent the most problematic outputs from reaching users. But these are all imperfect solutions that create trade-offs between different types of problems.

What does this mean for you as someone who uses AI systems?

First, understand that AI responses reflect the biases and limitations of their training data. When you encounter problematic AI behavior, you're often seeing amplified human biases rather than artificial malice.

Second, recognize that different AI systems will have different behavioral patterns based on their training data and alignment techniques. Understanding these differences helps you choose appropriate tools for different tasks.

Third, maintain critical thinking about AI outputs. These systems can be incredibly helpful while also perpetuating misconceptions or biases. Your judgment remains essential for evaluating whether AI responses are appropriate for your specific context.

Fourth, contribute to better AI development by providing thoughtful feedback when systems behave poorly. Many companies use user feedback to improve their alignment techniques.

Here's your framework for thinking about AI training data issues: What kind of patterns might this AI system have learned from its training data? How might those patterns affect its responses to my questions? What additional context or critical evaluation should I apply to its outputs?

This awareness doesn't mean avoiding AI systems, but using them more thoughtfully and maintaining appropriate skepticism about their responses.

The training data challenge also reveals something important about human knowledge and communication. The internet contains our collective wisdom and our collective foolishness, our highest aspirations and our worst impulses, all mixed together without clear boundaries.

AI systems that learn from this data force us to confront uncomfortable truths about the information ecosystem we've created and the biases embedded in our own communication patterns.

Remember: AI systems learn from the full spectrum of human expression online, including both wisdom and foolishness. Pattern recognition without understanding means AI absorbs biases along with knowledge. Internet data isn't representative of human diversity, creating skewed AI perspectives. No perfect solution exists for curating human knowledge at the scale AI requires. And maintaining critical thinking about AI outputs helps you benefit from their capabilities while avoiding their limitations.

Tomorrow, notice one moment when an AI system gives you a response that seems biased, inappropriate, or just doesn't match your expectations. <break time="0.3s" /> Consider what patterns in human communication the system might have learned that led to that particular response.

Share an example of AI behavior that made you think "where did that come from?" These moments reveal the complex relationship between training data and AI behavior.

Next time, we'll explore how AI systems that learn from human biases force us to confront uncomfortable truths about ourselves, and why this mirror effect might be the most important thing artificial intelligence teaches us.

Thanks for joining me as we explore the messy reality of how AI systems learn from human knowledge. The internet as a classroom reveals as much about us as it does about artificial intelligence.