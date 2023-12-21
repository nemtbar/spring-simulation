class Slider2{
    int posx, posy, wid, hei, g_value;
    float g_buttonx, g_buttony, g_min, g_max, radius, value_min, value_max, l_value;
    PVector _color;
    String name;
    Slider2(String kname, int kposx, int kposy, int kwid, int khei, float kmin, float kmax, float value, PVector kcolor){
        /*
        l_ means local
        g_ means global
        */
        posx = kposx;
        posy = kposy;
        wid = kwid;
        hei = khei;
        l_value = value;
        value_min = kmin;
        value_max = kmax;
        g_min = posx + wid/20;
        g_max = posx + wid - wid/20;
        g_value = int(g_min) + int(l_value);
        g_buttonx = g_min + l_value;
        g_buttony = posy + hei/2;
        radius = hei/2;
        _color = kcolor;
        name = kname;
    }
    void show(){
        fill(255, 255, 255);
        rect(posx, posy, wid, hei);
        fill(_color.x, _color.y, _color.z);
        rect(g_min, posy+hei/4, l_value, hei-hei/4*2);
        fill(255, 0, 0);
        circle(g_buttonx, g_buttony, radius);
        fill(0, 0, 0, 255);
        String rubber = new String(str(map(g_value, g_min, g_max, value_min, value_max)));
        text(name+":"+rubber, g_min, posy+hei/2);

    }
    void grab(){
        if (dist(mouseX, mouseY, g_buttonx, g_buttony) < radius && mousePressed){
            g_value = mouseX;
            if (g_value < g_min){
                g_value = int(g_min);
            } else if (g_value > g_max){
                g_value = int(g_max);
            }
        }

    }
    void update(){
        l_value = g_value - int(g_min);
        g_buttonx = g_value;

    }
    float get_value(){
        return map(g_value, g_min, g_max, value_min, value_max);
    }

    void frame(){
        grab();
        update();
        show();
    }

}

class Particle{
    boolean locked, picked;
    PVector velocity, acceleration, pos;
    Particle(boolean locke, PVector po){
        locked = locke;
        velocity = new PVector(0, 0);
        acceleration = new PVector(0, 0);
        pos = po;
        picked = false;
    }
    void show(){
        push();
        fill(255, 255, 255);
        noStroke();
        circle(pos.x, pos.y, 5);
        pop();

    }

    void update(){
        if (!locked){
            velocity.add(acceleration);
            pos.add(velocity);
            velocity.mult(0.96);
            if (picked){
                pos.x = mouseX;
                pos.y = mouseY;
                velocity.mult(0);
            }
        }
        acceleration.mult(0);
    }

    void apply(PVector force){
        acceleration.add(force);
    }
}

class Spring{
    Particle[] spring;
    float len;
    PVector rope;
    Spring(PVector start_poin, PVector end_poin, int densit){
        spring = new Particle[densit];
        rope = PVector.sub(end_poin, start_poin);
        len = rope.mag()/(densit-1);
        rope.div(densit-1);
        for (int i = 0; i < densit; i++){
            PVector sol = PVector.add(start_poin, PVector.mult(rope, i));
            sol.x = round(sol.x);
            sol.y = round(sol.y);
            if (i == 0){
                spring[i] = new Particle(true, sol);
            }else if (i == spring.length-1){
                spring[i] = new Particle(true, sol);
            }else{
                spring[i] = new Particle(false, sol);  
            }
        }
        
    }

    void release(){
        for (int i = 0; i< spring.length; i++){
            spring[i].picked = false;
        }
    }

    void attract(float k){
        for (int i = 1; i<spring.length; i++){
            PVector force = PVector.sub(spring[i-1].pos, spring[i].pos);
            float ext = force.mag() - len;
            force.normalize();
            force.mult(-k*ext);
            spring[i-1].apply(force);
        }
    }

    void show(){
        push();
        fill(255, 255, 255);
        stroke(255, 255, 255);
        spring[0].show();
        for (int i = 1; i < spring.length; i++){
            line(spring[i].pos.x, spring[i].pos.y, spring[i-1].pos.x, spring[i-1].pos.y);
            spring[i].show();
        }
        pop();
    }

    void update(){
        boolean already = false;
        for (int i = 0; i < spring.length; i++){
            if (spring[i].picked == true){
                already = true;
                break;
            }
        }
        for (int i = 0; i<spring.length; i++){
            if (mousePressed && dist(spring[i].pos.x, spring[i].pos.y, mouseX, mouseY) < 15 && !already){
                spring[i].picked = true;
            }

            spring[i].update();
        }

    }
}
//k is springiness
float k = 0.8;
Spring rubber;
Slider2 slid;
void setup(){
    fullScreen();
    rubber = new Spring(new PVector(10, height/2), new PVector(width-10, height/2), 40);
    slid = new SLider2("k", 30, 30, 100, 20, 0.0005, 0.8, 0.8, new PVector(252, 252, 3));
}

void draw(){
    background(245, 199, 108);
    stroke(255, 255, 255);
    rubber.attract(k);
    rubber.update();
    rubber.show();
    //calls every necessary function to slider
    slid.frame();
    k = slid.get_value();
}

void mouseReleased() {
        rubber.release();
}
