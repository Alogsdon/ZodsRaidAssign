# ZodsRaidAssign
<h2>Installation</h2>
download a release<br>
extract the release to your addon folder<br>
edit the folder name so it is exactly <code>ZodsRaidAssign</code> (i.e. remove the "-1.0" or "-master")<br>
<br>
<h2>Commands</h2>
<h3>primary commands you may actually use</h3>
<code>/zra</code> opens assignment window<br>
<code>/zra save {tag}</code> saves your current raid assignments so you can load later<br>
<code>/zra load {tag}</code> loads a saved raid assignment. if you leave {tag} blank, it will print a list of saved tags<br>

<h3>some extra commands that are in there</h3>
<code>/zra delete {tag</code> deletes an old raid assignment. idk why you'd want to. maybe you think the file is too big or something<br>
<code>/zra test1</code> or <code>/zra test1</code> loads a dummy raid so you can test the addon<br>
<code>/zra i</code> lists times when you left instances, good for keeping track of hourly instance lockouts<br>
<code>/zra wipe</code> works with the instance lockout tracking, lets the addon know you are re-entering a non-fresh instance (*theres not really a good way to detect that*)<br>

<br>
<h2>brief walkthrough</h2>

once you have it installed, just use the command `/zra` to open the main window <br>
it will probably be blank when you first open it like this
![roles tab](https://github.com/Alogsdon/ZodsRaidAssign/blob/master/images/Empty.png)
<br>
hit the populate button at the bottom left to add all of your current raid members to the window
![roles tab](https://github.com/Alogsdon/ZodsRaidAssign/blob/master/images/populated.png)
<br>
Now you can do the role assignments. It has an autofill feature to save you some time. Hit autofill at the top left and it will assume some roles for people. These role assignments will be used to generate raid assignments in other tabs. Adjust your tanks/healers in the order you want them to be assigned. (i.e. put your main tank at the top of the column and so on, likewise for healers) You can just click and drag them to where you want them.
![roles tab](https://github.com/Alogsdon/ZodsRaidAssign/blob/master/images/RolesTab.png)
<br>
Now go to a raid tab (e.g. Molten Core) There is a dropdown for all the bosses, you can always Auto Fill these assignments. Hit "Post" to post the assignments in a raid warning (or just raid if you dont have assistant). 
![roles tab](https://github.com/Alogsdon/ZodsRaidAssign/blob/master/images/Gehennas.png)
<br>
These assignments are automatically synced up with other users who are using the addon. If you think someone else is messing with assignments, you can check the "Log" tab, it shows pretty much everything you or other people changed.
![roles tab](https://github.com/Alogsdon/ZodsRaidAssign/blob/master/images/Log.png)


