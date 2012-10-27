import pyglet

from pyglet.gl import *

 

win = pyglet.window.Window()

 

@win.event

def on_draw():




        # Clear buffers

        glClear(GL_COLOR_BUFFER_BIT)


		glLoadIdentity();

	
		glBegin(GL_QUADS);	
		FOR i:= 0 TO Base.W-2 DO 
			j3:=0; 
			FOR j := 0 TO Base.H-2 DO	
				glColor3f(Base.rays[i,j].r, Base.rays[i,j].g, Base.rays[i,j].b); 
				glVertex2f(i3,j3);
				glColor3f(Base.rays[i+1,j].r, Base.rays[i+1,j].g, Base.rays[i+1,j].b); 
				glVertex2f(i3+PX,j3);
				glColor3f(Base.rays[i+1,j+1].r, Base.rays[i+1,j+1].g, Base.rays[i+1,j+1].b); 
				glVertex2f(i3+PX,j3+PX);
				glColor3f(Base.rays[i,j+1].r, Base.rays[i,j+1].g, Base.rays[i,j+1].b); 
				glVertex2f(i3,j3+PX);	
				j3:=j3+PX
			END;
			i3:=i3+PX
		END;
	
   

        glEnd()

 
pyglet.app.run()
