---
title: NPC Playground
emoji: 🤖
colorFrom: indigo
colorTo: pink
sdk: static
app_file: ./cubzh.html
pinned: false
license: mit
disable_embedding: true
custom_headers:
  cross-origin-embedder-policy: require-corp
  cross-origin-opener-policy: same-origin
  cross-origin-resource-policy: cross-origin
---

# NPC Playground 🕹️🤖

[![Join the chat at https://cu.bzh/discord](https://img.shields.io/discord/355905150528913409?color=%237289DA&label=cubzh&logo=discord&logoColor=white)](https://cu.bzh/discord)

3D playground to interact with LLM-powered NPCs. </br>
Clone and modify `cubzh.lua` file to teach them new skills with a few lines of code!

<div align="center">
<img style="max-width: 800px; width: 80%;" alt="cubzh_gigax_hf" src="https://github.com/soliton-x/ai-npc/assets/33256624/e62dd138-c018-4ecf-bc77-a072fadb5c12">
</div>

[Play](#Play) |
[Customize](#Customize) |
[Scripting](#Scripting) |
[Course](#Course) |
[Credits](#Credits)


## Play 

Just go to [huggingface.co/spaces/cubzh/ai-npcs](https://huggingface.co/spaces/cubzh/ai-npcs).

Engage with NPCs and try to trigger some of those pre-installed skills: `move`, `follow`, `jump`, `explode` (you may need to insist for that one 😅).

## Customize

1. Clone [huggingface.co/spaces/cubzh/ai-npcs](https://huggingface.co/spaces/cubzh/ai-npcs) repository. **⚠️ clone needs to be public ⚠️**
2. Modify and commit [`world.lua`](https://huggingface.co/spaces/cubzh/ai-npcs/blob/main/world.lua) file to edit NPC skills.
3. That's it!

## Scripting

### **Tweaking NPC Behavior**

Modify the predifined fields in `world.lua`'s `NPCs` table in order to influence NPC behaviour:

```lua
local NPCs = {    
  {
    name = "npcscientist",
    physicalDescription = "A small sphere with a computer screen for a face",
    psychologicalProfile = "Designed to be helpful to any human it interacts with, this robot viscerally hates squirrels.",
    currentLocationName = "Scientist Island",
    initialReflections = {
      "This NPC is a robot that punctuates all of its answers with electronic noises - as any android would!",
      ...
    },
  },
  ...
}
```
 
### **Teaching NPCs new skills** 

Our NPCs have been trained to use any skill you've defined before running the game. This is achieved by training the LLM powering them to do "function calling". 

Modify `skills` table in `world.lua` to give your NPCs new skills:

```lua
local skills = {
	{
    name = "SAY",
    description = "Say smthg out loud",
    parameter_types = {"character", "content"},
    callback = function(client, action)
      local npc = client:getNpc(action.character_id)
      if not npc then print("Can't find npc") return end
        dialog:create(action.content, npc.avatar)
      print(string.format("%s: %s", npc.name, action.content))
    end,
    action_format_str = "{protagonist_name} said '{content}' to {target_name}"
  },
  ...
}
```

The `callback` function is called whenever an NPC uses the skill, using the parameters defined in the `parameters` field. We've given you some examples in `skills.lua`, feel free to draw inspiration from them!

If you want to go deeper with Cubzh scripting API, here's the [documentation](https://docs.cu.bzh), the team and community will also be glad to help you on [Discord](https://cu.bzh/discord).

### Environment Design (👷‍♂️ work in progress 🏗️)
 
Cubzh allows you to modify the 3D environment, by importing community-made voxel assets or creating new ones yourself. It's not yet possible to modify the environment yet though in the context of that specific demo, but we're working on making it possible, stay tuned!

## Course

Together with the HuggingFace staff, we've released a new course to teach you how to create your own NPC skills with Lua. You can access it [here](https://huggingface.co/learn/ml-games-course/en/unit3/introduction)

## Credits

- [Hugging Face](https://huggingface.co/) 🤗
- [Gigax](https://github.com/GigaxGames)
- [Cubzh](https://cu.bzh): A versatile UGC (User-Generated Content) gaming platform.
- **You !** You're welcome to **duplicate** the repo, share your creations, and submit PRs here :)


