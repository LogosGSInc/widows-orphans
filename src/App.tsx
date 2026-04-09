import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { GovernanceGate } from './components/GovernanceGate';
import { MapView } from './screens/MapView';

export default function App() {
  return (
    <GovernanceGate>
      <BrowserRouter basename={import.meta.env.BASE_URL}>
        <Routes>
          <Route path="*" element={<MapView />} />
        </Routes>
      </BrowserRouter>
    </GovernanceGate>
  );
}
