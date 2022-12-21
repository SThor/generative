public class Tile {
  float originX;
  float originY;
  float sideLength;
  float spacing;

  boolean topUsed;
  boolean bottomUsed;
  boolean leftUsed;
  boolean rightUsed;

  public void draw() {
    if (topUsed) {
      if (bottomUsed) {
        if (leftUsed) {
          if (rightUsed) {
          } else {
          }
        } else {
          if (rightUsed) {
          } else {
            for ( float i=0; i<sideLength; i+=spacing){
              
            }
          }
        }
      } else {
        if (leftUsed) {
          if (rightUsed) {
          } else {
          }
        } else {
          if (rightUsed) {
          } else {
          }
        }
      }
    } else {
      if (bottomUsed) {
        if (leftUsed) {
          if (rightUsed) {
          } else {
          }
        } else {
          if (rightUsed) {
          } else {
          }
        }
      } else {
        if (leftUsed) {
          if (rightUsed) {
          } else {
          }
        } else {
          if (rightUsed) {
          } else {
          }
        }
      }
    }
  }
}
