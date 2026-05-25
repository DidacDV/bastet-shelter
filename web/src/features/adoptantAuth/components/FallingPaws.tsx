import { useState } from "react";

import paw1 from "../../../assets/images/paws/cat-face-emoji-svgrepo-com.svg";
import paw2 from "../../../assets/images/paws/cat-silhouette-svgrepo-com.svg";
import paw3 from "../../../assets/images/paws/paw-cat-pet-svgrepo-com.svg";
import paw4 from "../../../assets/images/paws/dog-svgrepo-com.svg";

const PAW_SVGS = [paw1, paw2, paw3, paw4];
const PAW_COLORS = [
  "invert(23%) sepia(51%) saturate(800%) hue-rotate(214deg) brightness(85%)", //iris
  "invert(52%) sepia(60%) saturate(500%) hue-rotate(214deg) brightness(105%)", //secondary
  "invert(78%) sepia(60%) saturate(600%) hue-rotate(5deg) brightness(105%)", //apricot
  "invert(58%) sepia(70%) saturate(500%) hue-rotate(350deg) brightness(95%)", //deepOrange
];

interface Paw {
  id: number;
  x: number; //% from left
  delay: number; //seconds
  duration: number;
  size: number;
  opacity: number;
  rotation: number;
  svgIndex: number;
}

function generatePaws(count: number): Paw[] {
  return Array.from({ length: count }, (_, i) => ({
    id: i,
    x: Math.random() * 90 + 5,
    delay: Math.random() * 8,
    duration: Math.random() * 6 + 10,
    size: Math.random() * 20 + 10,
    opacity: Math.random() * 0.25 + 0.08,
    rotation: Math.random() * 40 - 20,
    svgIndex: Math.floor(Math.random() * 4),
  }));
}

export default function FallingPaws({ count = 18 }: { count?: number }) {
  const [paws] = useState<Paw[]>(() => generatePaws(count));

  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      <style>{`
        @keyframes fall {
          0%   { transform: translateY(-60px) rotate(var(--rot)); opacity: 0; }
          10%  { opacity: var(--op); }
          90%  { opacity: var(--op); }
          100% { transform: translateY(calc(100vh + 60px)) rotate(calc(var(--rot) + 15deg)); opacity: 0; }
        }
      `}</style>

      {paws.map((paw) => (
        <img
          key={paw.id}
          src={PAW_SVGS[paw.id % PAW_SVGS.length]}
          alt=""
          style={
            {
              position: "absolute",
              left: `${paw.x}%`,
              top: "-60px",
              width: `${paw.size}px`,
              height: `${paw.size}px`,
              "--rot": `${paw.rotation}deg`,
              "--op": paw.opacity,
              animation: `fall ${paw.duration}s ${paw.delay}s infinite linear`,
              filter: PAW_COLORS[paw.svgIndex],
            } as React.CSSProperties
          }
        />
      ))}
    </div>
  );
}
